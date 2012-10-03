class FundingAllocationsByProgramReport < ActionController::ReportBase
  include FundingAllocationsBaseReport
  set_type_as_show

  def report_label
    "Budget Overview Chart (Annual Tracker)"
  end

  def report_description
    "Data visualization to track Program's annual budgeting and grant throughput. (Bar Chart)"
  end

  def compute_show_plot_data controller, index_object, params
    filter = params["active_record_base"]
    hash = {}
    hash[:title] = report_label
    FundingSourceAllocation.build_temp_table do |temp_table_name|

      program_ids= ReportUtility.get_program_ids filter["program_id"]
      start_date, stop_date = get_date_range filter
      years = ReportUtility.get_years start_date, stop_date

      # Never include these requests
      rejected_states = Request.send(:sanitize_sql, ['(?)', Request.all_rejected_states])
      # TODO: this isn't working
#      paid_states = Request.send(:sanitize_sql, ['(?)', RequestTransaction.all_states_with_category('paid').map{|state| state.to_s}])
      paid_states = "('paid')"

      always_exclude = "r.deleted_at IS NULL AND r.state not in #{rejected_states}"

      # Selected Programs
      query = "SELECT name, id FROM programs WHERE id IN (?)"
      programs = ReportUtility.query_map_to_array([query, program_ids], program_ids, "id", "name", false)
      xaxis = []
      i = 0
      programs.each { |program| xaxis << program }
      #Total Granted
      query = "SELECT sum(amount_recommended) as amount, program_id FROM requests r WHERE #{always_exclude} AND granted = 1 AND grant_agreement_at >= ? AND grant_agreement_at <= ? AND program_id IN (?) GROUP BY program_id"
      total_granted = ReportUtility.query_map_to_array([query, start_date, stop_date, program_ids], program_ids, "program_id", "amount")

      #Paid
      query = "select sum(rtfs.amount) AS amount,  fsa.program_id AS program_id from request_transactions rt, request_transaction_funding_sources rtfs, request_funding_sources rfs, #{temp_table_name} fsa, requests r
        WHERE #{always_exclude} AND rt.state in #{paid_states} AND rt.id = rtfs.request_transaction_id AND rfs.id = rtfs.request_funding_source_id AND fsa.id = rfs.funding_source_allocation_id AND r.id = rt.request_id
        AND r.grant_agreement_at >= ? AND r.grant_agreement_at <= ? AND fsa.program_id IN (?) and rt.deleted_at is null GROUP BY fsa.program_id"
      paid = ReportUtility.query_map_to_array([query, start_date, stop_date, program_ids], program_ids, "program_id", "amount")

      #Budgeted
      query = "SELECT SUM(tmp.amount) AS amount, tmp.program_id AS program_id FROM #{temp_table_name} tmp WHERE tmp.retired=0 AND tmp.deleted_at IS NULL AND tmp.program_id IN (?) AND tmp.spending_year IN (?) GROUP BY tmp.program_id"
      budgeted = ReportUtility.query_map_to_array([query, program_ids, years], program_ids, "program_id", "amount")

      #Pipeline
      #TODO: Check this
      query = "SELECT SUM(r.amount_requested) AS amount, r.program_id as program_id FROM requests r  WHERE #{always_exclude} AND r.granted = 0 AND r.program_id IN (?) AND r.state NOT IN (?) GROUP BY r.program_id"
      pipeline = ReportUtility.query_map_to_array([query, program_ids, ReportUtility.pre_pipeline_states], program_ids, "program_id", "amount")

      hash = {:library => "jqPlot"}

      hash[:data] = [budgeted, pipeline, total_granted, paid]

      hash[:axes] = { :xaxis => {:ticks => xaxis, :tickOptions => { :angle => -30 }}, :yaxis => { :min => 0, :tickOptions => { :formatString => "#{I18n.t 'number.currency.format.unit'}%.2f" }}}
      hash[:series] = [ {:label => "Budgeted"}, {:label => "Pipeline"}, {:label => "Granted"}, {:label => "Paid"} ]
      hash[:stackSeries] = false;
      hash[:type] = "bar"
    end
    hash.to_json
  end

end
