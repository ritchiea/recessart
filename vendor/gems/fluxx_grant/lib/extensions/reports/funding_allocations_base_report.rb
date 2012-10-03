module FundingAllocationsBaseReport

  def initialize report_id
    super report_id
    self.filter_template = 'modal_reports/funding_year_and_program_filter'
  end

  def report_description
    "View current status of each allocation - amount spent, in the pipeline and allocated"
  end

  def get_date_range filter
    start_string = '1/1/' + filter["funding_year"] if filter && filter["funding_year"]
    start_date = if start_string
      Date.parse(start_string)
    else
      Time.at(0).to_date
    end
    return start_date, start_date.end_of_year()
  end

  def report_filter_text controller, index_object, params
    start_date, stop_date = get_date_range params["active_record_base"]
    "#{start_date.strftime('%B %d, %Y')} to #{stop_date.strftime('%B %d, %Y')}"
  end

  def report_summary controller, index_object, params
    filter = params["active_record_base"]
    start_date, stop_date = get_date_range filter
    program_ids= if filter
      ReportUtility.get_program_ids filter["program_id"]
    end || []
    query = "SELECT id FROM requests WHERE deleted_at IS NULL AND state <> 'rejected' and granted = 1 and grant_agreement_at >= ? and grant_agreement_at <= ? and program_id in (?)"
    request_ids = ReportUtility.array_query([query, start_date, stop_date, program_ids])
    hash = ReportUtility.get_report_totals request_ids
    "#{hash[:grants]} Grants totaling #{number_to_currency(hash[:grants_total])} and #{hash[:fips]} #{I18n.t(:fip_name).pluralize} totaling #{number_to_currency(hash[:fips_total])}"
  end

  def report_legend controller, index_object, params
    filter = params["active_record_base"]
    start_date, stop_date = get_date_range filter
    years = ReportUtility.get_years start_date, stop_date
    program_ids= if filter
      ReportUtility.get_program_ids filter["program_id"]
    end || []
    always_exclude = "r.deleted_at IS NULL AND r.state <> 'rejected'"
    legend = [{:table => ["Status", "Grants", "Grant #{CurrencyHelper.current_long_name.pluralize}", I18n.t(:fip_name).pluralize, "#{I18n.t(:fip_name)} #{CurrencyHelper.current_long_name.pluralize}"], :filter => "", "listing_url".to_sym => "", "card_title".to_sym => ""}]
    categories = ["Budgeted", "Pipeline", "Granted", "Paid"]
    start_date_string = start_date.strftime('%m/%d/%Y')
    stop_date_string = stop_date.strftime('%m/%d/%Y')
    FundingSourceAllocation.build_temp_table do |temp_table_name|
      categories.each do |program|
        card_filter = ""
        card_title = program
        listing_url = controller.granted_requests_path
        case program
        when "Granted"
          query = "SELECT SUM(r.amount_recommended) AS amount, count(r.id) AS count FROM requests r WHERE #{always_exclude} AND granted = 1 AND grant_agreement_at >= ? AND grant_agreement_at <= ? AND program_id IN (?) AND type = ?"
          grant = [query, start_date, stop_date, program_ids, 'GrantRequest']
          fip = [query, start_date, stop_date, program_ids, 'FipRequest']
          card_filter ="utf8=%E2%9C%93&request%5Bdate_range_selector%5D=funding_agreement&request%5Brequest_from_date%5D=#{start_date_string}&request%5Brequest_to_date%5D=#{stop_date_string}&request%5B2has_been_rejected%5D=&request%5Bsort_attribute%5D=updated_at&request%5Bsort_order%5D=desc&request[program_id][]=" + program_ids.join("&request[program_id][]=")
        when "Paid"
          query = "select sum(rtfs.amount) AS amount, COUNT(DISTINCT r.id) AS count from request_transactions rt, request_transaction_funding_sources rtfs, request_funding_sources rfs, #{temp_table_name} fsa, requests r
            WHERE #{always_exclude} AND rt.state = 'paid' AND rt.id = rtfs.request_transaction_id AND rfs.id = rtfs.request_funding_source_id AND fsa.id = rfs.funding_source_allocation_id AND r.id = rt.request_id
            AND r.grant_agreement_at >= ? AND r.grant_agreement_at <= ? AND fsa.program_id IN (?) AND type = ? and rt.deleted_at is null"
          grant = [query, start_date, stop_date, program_ids, 'GrantRequest']
          fip = [query, start_date, stop_date, program_ids, 'FipRequest']  
        when "Budgeted"
          query = "SELECT SUM(tmp.amount) AS amount FROM #{temp_table_name} tmp WHERE tmp.retired=0 AND tmp.deleted_at IS NULL AND tmp.program_id IN (?) AND tmp.spending_year IN (?)"
          grant = [query, program_ids, years]
          fip = [query, program_ids, years]
        when "Pipeline"
          query = "SELECT SUM(r.amount_requested) AS amount, COUNT(DISTINCT r.id) AS count FROM requests r  WHERE #{always_exclude} AND r.granted = 0 AND r.program_id IN (?) AND type = ? AND r.state NOT IN (?)"
          grant = [query, program_ids, 'GrantRequest', ReportUtility.pre_pipeline_states]
          fip = [query, program_ids, 'FipRequest', ReportUtility.pre_pipeline_states]
          filter_states = "&request[filter_state][]=" + (GrantRequest.all_states).select{|state| ReportUtility.pre_pipeline_states.index(state.to_s).nil? }.join("&request[filter_state][]=")
          card_filter ="utf8=%E2%9C%93&request%5Bsort_attribute%5D=updated_at&request%5Bsort_order%5D=desc&request[program_id][]=" + program_ids.join("&request[program_id][]=") + filter_states
          listing_url = controller.grant_requests_path
        end
        grant_result = ReportUtility.single_value_query(grant)
        fip_result = ReportUtility.single_value_query(fip)
        legend << { :table => [program, grant_result["count"], number_to_currency(grant_result["amount"] ? grant_result["amount"] : 0 ), fip_result["count"], number_to_currency(fip_result["amount"] ? fip_result["amount"] : 0)],
                    :filter => card_filter, "listing_url".to_sym => listing_url, "card_title".to_sym => card_title}
      end
    end
   legend
  end

end
