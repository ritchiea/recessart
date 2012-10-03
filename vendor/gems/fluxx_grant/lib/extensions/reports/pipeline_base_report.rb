module PipelineBaseReport
  def load_results params, pipeline_type
    active_record_params = params[:active_record_base] || {}
    start_date = if active_record_params[:start_date].blank?
      nil
    else
      Time.parse(active_record_params[:start_date]) rescue nil
    end
    end_date = if active_record_params[:end_date].blank?
      nil
    else
      Time.parse(active_record_params[:end_date]) rescue nil
    end
    spending_year = active_record_params[:spending_year]

    granted = (active_record_params[:granted] || []).index('1') ? 1 : 0
    query_types = []
    types = active_record_params[:include] || []
    query_types << 'GrantRequest' if types.index 'Grants'
    query_types << 'FipRequest' if types.index I18n.t(:fip_name).pluralize
  
    is_type_org = (pipeline_type == 'organization')
    is_type_request = (pipeline_type == 'request')
  
    temp_select_fields = if is_type_org
      " if(organizations.parent_org_id is not null, organizations.parent_org_id, organizations.id) id, (select name from organizations suborg where suborg.id = (if(organizations.parent_org_id is not null, organizations.parent_org_id, organizations.id))) "
    elsif is_type_request
      "requests.id, base_request_id"
    end
  
    FundingSourceAllocation.build_temp_table do |temp_table|
      # TODO ESH: add support for filtering by program_id, sub_program_id and funding_source_id
  
      # Note that the amount_requested, amount_recommended is incorrect for org_type because it is grouping multiple requests together so you just get the last amount instead of the sum.
      #  Further note that if you do a simple SUM, you get doublecounting because the same request is counted multiple times per funding request
      report_temp_table_name = 'pipeline_report_temp_table'
      Request.connection.execute "DROP TABLE IF EXISTS #{report_temp_table_name}"
      Request.connection.execute(Request.send :sanitize_sql, ["create temporary table #{report_temp_table_name}
         SELECT #{temp_select_fields} entity_name, amount_requested, amount_recommended, funding_source_allocations.program_id, funding_source_allocations.sub_program_id, 
           request_funding_sources.funding_amount funding_amount, 
           (select sum(rtfs.amount) from request_transaction_funding_sources rtfs, request_transactions where request_funding_source_id = request_funding_sources.id and request_transactions.id = rtfs.request_transaction_id and request_transactions.state in (?) and request_transactions.deleted_at is null) paid_amount
        FROM requests, request_funding_sources #{is_type_org ? ', organizations' : ''}, #{temp_table} funding_source_allocations
        WHERE requests.id = request_funding_sources.request_id AND requests.deleted_at IS NULL AND requests.state not in (?) #{(granted.to_s == '1' && start_date) ? " AND grant_agreement_at >= '#{start_date.sql}' " : ''} 
              #{(granted.to_s == '1' && end_date) ? " AND grant_agreement_at <= '#{end_date.sql}' " : ''} AND granted = #{granted} #{Request.prepare_request_types_for_where_clause(query_types)}
              #{is_type_org ? ' AND requests.program_organization_id = organizations.id ' : ''} 
              AND funding_source_allocations.id = request_funding_sources.funding_source_allocation_id
              #{spending_year ? " AND spending_year = #{spending_year} " : ''}", RequestTransaction.all_states_with_category('paid').map{|state| state.to_s}, Request.all_rejected_states])
      
      sql_clause = "SELECT id, entity_name, amount_requested, amount_recommended, program_id, sub_program_id, 
                 sum(funding_amount) funding_amount, 
                 sum(paid_amount) paid_amount
        FROM #{report_temp_table_name}
        GROUP by id, entity_name, program_id, sub_program_id"
  
      models = Request.find_by_sql sql_clause
      
      Request.connection.execute "DROP TABLE IF EXISTS #{report_temp_table_name}"
      
      [models, start_date, end_date, spending_year, query_types]
    end
  end
  
  def process_results models
    programs = Program.find :all #, :conditions => 'retired <> 1 and rollup <> 1'
    sub_programs = SubProgram.find :all, :include => :program, :conditions => ['program_id in (?)', programs.map(&:id)]
    # Build the data structure required to output the grants
    # Data structure looks something like this for a :
    # {13014 => {:amount => 100000, :entity_name => '0808-13014', :sub_programs => {2 => {:funding_amount => 25000, :paid_amount => 12500}, 4 => {:funding_amount => 75000, :paid_amount => 0}}}}
    #   Where:
    #     13014 is the request id
    #     0808-13014 is the entity_name
    #     2 is the Power sub_program
    #     4 is the Transportation sub_program
    request_data = models.inject({}) do |acc, model|
      request_map = acc[model.id] || {}
      acc[model.id] = request_map
      request_map[:entity_name] = model.entity_name
      request_map[:amount] = model.amount_recommended
      program_request_map = request_map[:sub_programs] || {}
      request_map[:sub_programs] = program_request_map
      program_request_map[model.sub_program_id] = {:funding_amount => model.funding_amount, :paid_amount => model.paid_amount}
      acc
    end
  
    # Make a list of all sub_program IDs that were actually used
    used_subprogram_ids = request_data.keys.map do |rd_key|
      rd = request_data[rd_key]
      rd[:sub_programs].keys
    end.flatten
    sub_programs = sub_programs.reject{|sp| !(used_subprogram_ids.include?(sp.id))}
    [request_data, sub_programs]
  end
end