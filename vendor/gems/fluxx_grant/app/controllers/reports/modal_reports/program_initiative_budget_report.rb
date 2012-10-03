class ProgramInitiativeBudgetReport < ActionController::ReportBase
  include PipelineBaseReport
  
  set_type_as_show
  set_order 5
  
  def initialize report_id
    super report_id
    self.filter_template = 'modal_reports/program_initiative_budget_filter'
  end
  
  def report_label
    'Financial Details by Initiative'
  end

  def report_description
    'Detailed grant listing of Program/Initiative spending - by Budget, Pipeline, Commit, and Paid.  (Excel Report)'
  end
  
  def compute_show_document_headers controller, show_object, params
    ['fluxx_' + 'program_initiative_budget' + '_' + Time.now.strftime("%m%d%y") + ".xls", 'application/vnd.ms-excel']
  end
  
  def compute_show_document_data controller, show_object, params
    models, start_date, end_date, spending_year, query_types = load_results params, 'request'
    request_data, sub_programs = process_results models
    
    # Make a hash of the requests, grab the ids of all and look up the associated org
    # {13014 => {:amount => 100000, :grant_title => 'The Energy Foundation', :type => 'GrantRequest', :entity_name => '0808-13014', :sub_programs => {2 => 25000, 4 => 75000}}}
    Request.find_by_sql(["select requests.id id, if(type = 'GrantRequest', organizations.name, fip_title) grant_title, requests.type from requests left outer join organizations on requests.program_organization_id = organizations.id where requests.id in (?)", request_data.keys]).each do |req|
      if request_data[req.id]
        request_data[req.id][:grant_title] = req.grant_title
        translated_type = Request.translate_grant_type(req.type)
        request_data[req.id][:type] = translated_type ? translated_type.singularize : ''
      end
    end
    
    # Now build a list of programs -> sub_programs that lists all associated requests
    lookup_table_programs = {}
    lookup_table_sub_programs = SubProgram.find_by_sql(['select id, program_id, name from sub_programs where id in (?)', sub_programs.map(&:id)]).inject({}) do |acc, sub_program| 
      acc[sub_program.id] = sub_program
      lookup_table_programs[sub_program.program_id] = ''
      acc
    end
    
    lookup_table_programs = Program.find_by_sql(['select id, name from programs where id in (?)', lookup_table_programs.keys]).inject({}) do |acc, program| 
      acc[program.id] = {:program => program, :sub_programs => {}}
      acc
    end
    
    # Format of lookup_table_programs should be, where 5 is a program_id and 6 is a sub_program_id, 13014 is a request_id:
    # {5 => {:program => PROGRAM, 
    #     :sub_programs => {6 => 
    #        {13014 => {:amount => 100000, :grant_title => 'The Energy Foundation', :type => 'GrantRequest', :entity_name => '0808-13014', :sub_programs => {2 => 25000, 4 => 75000}}}}}}
    request_data.keys.each do |req_id|
      # request_hash is a hash of :amount, :grant_title, :entity_name, :sub_programs (hash of sub_program keys to their funding amounts for this request)
      request_hash = request_data[req_id]
      if request_hash && request_hash.is_a?(Hash)
        req_subprog_hash = request_hash[:sub_programs]

        # req_subprog_hash is a hash of sub_program keys to their funding amounts for this request
        if req_subprog_hash && req_subprog_hash.is_a?(Hash)
          req_subprog_hash.keys.each do |sub_program_id|
            sub_program = lookup_table_sub_programs[sub_program_id]
            if sub_program
              hash = lookup_table_programs[sub_program.program_id][:sub_programs][sub_program_id] || {}
              lookup_table_programs[sub_program.program_id][:sub_programs][sub_program_id] = hash
              hash[req_id] = request_hash
            end
          end
        end
      end
    end
    
    
    # now calculate 
    
    output = StringIO.new

    workbook = WriteExcel.new(output)
    worksheet = workbook.add_worksheet

    non_wrap_bold_format, bold_format, header_format, solid_black_format, amount_format, number_format, date_format, text_format, header_format, 
        sub_total_format, sub_total_border_format, total_format, total_border_format, final_total_format, final_total_border_format, 
        bold_total_format, double_total_format = build_formats(workbook)

    # Adjust column widths
    worksheet.set_column(0, 20+sub_programs.size, 15)


    # Add page summary
    # worksheet.write(0, 0, 'The Energy Foundation', non_wrap_bold_format)
    worksheet.write(1, 0, 'Detail Summary', non_wrap_bold_format)
    worksheet.write(2, 0, "Spending Year: " + spending_year)
    worksheet.write(3, 0, "Report Date: " + Time.now.mdy)


    [I18n.t(:program_name), I18n.t(:sub_program_name), "Grantee Name", "ID", "Type", "Budget", "Pipeline", "Committed",	"Paid"].
      each_with_index{|label, index| worksheet.write(5, index, label, header_format)}
    worksheet.set_column('A:H', 12)

    row_start = 5
    row = row_start
    
    # lookup_table_programs = {5 => {:program => PROGRAM, 
    #     :sub_programs => {6 => 
    #        {13014 => {:amount => 100000, :grant_title => 'The Energy Foundation', :type => 'GrantRequest', :entity_name => '0808-13014', :sub_programs => {2 => 25000, 4 => 75000}}}}}}
    
    # lookup_table_programs={1=>{:sub_programs=>{6=>{13016=>{:type=>\"Grants\", :amount=>60000, :grant_title=>\"Land Institute\", :sub_programs=>{6=>{:funding_amount=>\"10000\", :paid_amount=>nil}}, :entity_name=>\"1007-13016\"}}}, :program=>#<Program id: 1, name: \"Climate\">}}"
    total_rows = []
    lookup_table_programs.keys.map do |program_id|
      program_hash = lookup_table_programs[program_id]
      program = program_hash[:program]
      program_name = (program ? program.name : '')
      worksheet.write(row += 1, 0, program_name)
      sub_program_hash = program_hash[:sub_programs]
      sub_total_rows = []
      sub_program_hash.keys.map do |sub_program_id|
        sub_program = lookup_table_sub_programs[sub_program_id]
        sub_program_name = (sub_program ? sub_program.name : '')
        sub_program_budget = sub_program.total_allocation(:spending_year => spending_year)
        sub_program_pipeline = sub_program.total_pipeline(query_types)
        
        request_hashes = sub_program_hash[sub_program.id]
        worksheet.write(row += 1, 1, sub_program_name)
        worksheet.write(row, 5, sub_program_budget, amount_format)
        worksheet.write(row, 6, sub_program_pipeline, amount_format)
        start_row = stop_row = row + 1    
        request_hashes.keys.each do |request_id|
          # request_hash = {:type=>\"Grants\", :amount=>60000, :grant_title=>\"Land Institute\", :sub_programs=>{6=>{:funding_amount=>\"10000\", :paid_amount=>nil}}, :entity_name=>\"1007-13016\"}
          request_hash = request_hashes[request_id]
          worksheet.write(row += 1, 2, request_hash[:grant_title])
          worksheet.write(row, 3, request_hash[:entity_name])
          worksheet.write(row, 4, request_hash[:type])
          request_sub_program_amount = request_hash[:sub_programs][sub_program_id][:funding_amount].to_i rescue ''
          worksheet.write(row, 7, request_sub_program_amount, amount_format)
          request_sub_program_amount_paid = request_hash[:sub_programs][sub_program_id][:paid_amount].to_i rescue ''
          worksheet.write(row, 8, request_sub_program_amount_paid, amount_format)
          stop_row = row + 1
        end
        sub_total_rows << stop_row + 1
        worksheet.write(row += 1, 1, "Total - #{program_name}/#{sub_program_name}", sub_total_format)
        worksheet.write(row, 2, '', sub_total_format)
        worksheet.write(row, 3, '', sub_total_format)
        worksheet.write(row, 4, '', sub_total_format)
        # TODO add sum totals for this set of requests/sub_programs
        worksheet.write(row, 5, "=SUM(F#{start_row}:F#{stop_row})", sub_total_border_format)
        worksheet.write(row, 6, "=SUM(G#{start_row}:G#{stop_row})", sub_total_border_format)
        worksheet.write(row, 7, "=SUM(H#{start_row}:H#{stop_row})", sub_total_border_format)
        worksheet.write(row, 8, "=SUM(I#{start_row}:I#{stop_row})", sub_total_border_format)
      end
      worksheet.write(row += 1, 0, "Total - #{program_name}", total_format)
      worksheet.write(row, 1, '', total_format)      
      worksheet.write(row, 2, '', total_format)
      worksheet.write(row, 3, '', total_format)
      worksheet.write(row, 4, '', total_format)      
      # TODO add sum totals for this set of requests/programs
      total_rows << row + 1
      if (sub_total_rows.count > 0)
        worksheet.write(row, 5, "=SUM(F#{sub_total_rows.join(',F')})", total_border_format)
        worksheet.write(row, 6, "=SUM(G#{sub_total_rows.join(',G')})", total_border_format)
        worksheet.write(row, 7, "=SUM(H#{sub_total_rows.join(',H')})", total_border_format)
        worksheet.write(row, 8, "=SUM(I#{sub_total_rows.join(',I')})", total_border_format)
      else
        worksheet.write(row, 5, 0, total_border_format)
        worksheet.write(row, 6, 0, total_border_format)
        worksheet.write(row, 7, 0, total_border_format)
        worksheet.write(row, 8, 0, total_border_format)
     end    
    end
    worksheet.write(row += 1, 0, "Total", final_total_format)
    worksheet.write(row, 1, '', final_total_format)      
    worksheet.write(row, 2, '', final_total_format)
    worksheet.write(row, 3, '', final_total_format)
    worksheet.write(row, 4, '', final_total_format)      
    # TODO add sum totals for this set of requests/programs
    if (total_rows.count > 0)
      worksheet.write(row, 5, "=SUM(F#{total_rows.join(',F')})", final_total_border_format)
      worksheet.write(row, 6, "=SUM(G#{total_rows.join(',G')})", final_total_border_format)
      worksheet.write(row, 7, "=SUM(H#{total_rows.join(',H')})", final_total_border_format)
      worksheet.write(row, 8, "=SUM(I#{total_rows.join(',I')})", final_total_border_format)
    else
      worksheet.write(row, 5, 0, final_total_border_format)
      worksheet.write(row, 6, 0, final_total_border_format)
      worksheet.write(row, 7, 0, final_total_border_format)
      worksheet.write(row, 8, 0, final_total_border_format)
    end  
    workbook.close
    output.string
  end
end