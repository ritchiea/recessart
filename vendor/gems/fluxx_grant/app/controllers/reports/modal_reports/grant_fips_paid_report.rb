class GrantAndFipDetailsReport < ActionController::ReportBase
  set_type_as_show

  def initialize report_id
    super report_id
    self.filter_template = 'modal_reports/grant_and_fips_paid_filter'
  end

  def report_label
    'Payment Transaction Report'
  end

  def report_description
    'Detailed report on transactions recorded as paid.  (Excel Report)'
  end

  def compute_show_document_headers controller, show_object, params
    ['fluxx_' + 'grant_fips_paid' + '_' + Time.now.strftime("%m%d%y") + ".xls", 'application/vnd.ms-excel']
  end

  def compute_show_document_data controller, show_object, params
    active_record_params = params[:active_record_base] || {}
    
    case active_record_params[:date_range_type]
    when 'this_week'
      start_date = Time.now.ago(7.days)
      end_date = Time.now
    when 'last_week'
      start_date = Time.now.ago(14.days)
      end_date = Time.now.ago(7.days)
    else
      start_date = if active_record_params[:start_date].blank?
        nil
      else
        Time.parse(active_record_params[:start_date]) rescue nil
      end || Time.now
      end_date = if active_record_params[:end_date].blank?
        nil
      else
        Time.parse(active_record_params[:end_date]) rescue nil
      end || Time.now
    end

    query_types = []
    types = active_record_params[:include] || []
    query_types << 'GrantRequest' if types.index 'Grants'
    query_types << 'FipRequest' if types.index I18n.t(:fip_name).pluralize

    programs = params[:active_record_base][:program_id]
    programs = if params[:active_record_base][:program_id]
      Program.where(:id => params[:active_record_base][:program_id]).all rescue nil
    end || []
    programs = programs.compact
    
    requests = Request.find_by_sql [%{select req.type request_type, req.program_id, (select name from programs where programs.id = req.program_id) program_name,
      rt.payment_type, rt.payment_confirmation_number, payment_confirmed_by.first_name, payment_confirmed_by.last_name, rt.paid_at, 
      program_organization.name program_org_name, req.base_request_id, rt.amount_paid
      from request_transactions rt
      inner join requests req
      left outer join users payment_confirmed_by on payment_confirmed_by.id = rt.payment_recorded_by_id
      LEFT OUTER JOIN organizations program_organization ON program_organization.id = req.program_organization_id
      where 
      req.id = rt.request_id AND
      req.deleted_at IS NULL AND 
      rt.state in (?) AND
      rt.deleted_at is null AND
      req.state not in (?) AND
      paid_at is not null and paid_at >= ? and paid_at <= ?
      and amount_paid is not null
      and (1=? or req.program_id in (?))
      and (1=? or req.type in (?))}, 
      RequestTransaction.all_states_with_category('paid').map{|state| state.to_s}, Request.all_rejected_states,
      start_date, end_date, programs.empty?, programs, query_types.empty?, query_types
    ]
    
    hash_by_program = {}
    hash_by_type = requests.inject({}) do |acc, transaction|
      hash_by_program_id = acc[transaction.request_type] || {}
      acc[transaction.request_type] = hash_by_program_id
      
      hash_by_program[transaction.program_id] = transaction.program_id
      program_id_list = hash_by_program_id[transaction.program_id] || []
      hash_by_program_id[transaction.program_id] = program_id_list
      program_id_list << transaction
      acc
    end
    
    programs = Program.where(:id => hash_by_program.keys).all
    
    hash_by_program = {}
    programs.each{|program| hash_by_program[program.id] = program}

    
     output = StringIO.new

     workbook = WriteExcel.new(output)
     worksheet = workbook.add_worksheet
     
     non_wrap_bold_format, bold_format, header_format, solid_black_format, amount_format, number_format, date_format, text_format, header_format, 
         sub_total_format, sub_total_border_format, total_format, total_border_format, final_total_format, final_total_border_format, 
         bold_total_format, double_total_format = build_formats(workbook)

     # Add page summary
     # worksheet.write(0, 0, 'The Energy Foundation', non_wrap_bold_format)
     worksheet.write(1, 0, 'Payment Transaction Report', non_wrap_bold_format)
     worksheet.write(2, 0, 'Start Date: ' + start_date.mdy)
     worksheet.write(3, 0, 'End Date: ' + end_date.mdy)
     worksheet.write(4, 0, "Report Date: " + Time.now.mdy)

     # Adjust column widths
     worksheet.set_column(0, 9, 10)
     worksheet.set_column(1, 1, 15)
     worksheet.set_column(7, 7, 20)
     worksheet.set_column(9, 9, 15)


     ["Type", I18n.t(:program_name), "Paid By", "Check #", "First Name", "Last Name", "Paid At", "Name",	"Grant ID", "Amount"].
       each_with_index{|label, index| worksheet.write(5, index, label, header_format)}

     row_start = 6
     total_column_name = "J"
     row = row_start
     request_type_total_rows = []
     
     hash_by_type.keys.map do |request_type|
       worksheet.write(row += 1, 0, Request.translate_grant_type(request_type), header_format)
       program_transaction_hash = hash_by_type[request_type]
       program_total_rows = []
       program_transaction_hash.keys.map do |program_id|
         program = hash_by_program[program_id]
         worksheet.write(row += 1, 1, program ? program.name : program.id, header_format)
         request_transactions = program_transaction_hash[program_id]
         rt_start_row = row + 1
         request_transactions.each do |request_transaction|
           worksheet.write(row += 1, 2, request_transaction.payment_type)
           worksheet.write(row, 3, request_transaction.payment_confirmation_number)
           worksheet.write(row, 4, request_transaction.first_name)
           worksheet.write(row, 5, request_transaction.last_name)
           worksheet.write(row, 6, (request_transaction.paid_at ? (Time.parse(request_transaction.paid_at).mdy rescue '') : ''), date_format)
           worksheet.write(row, 7, request_transaction.program_org_name)
           worksheet.write(row, 8, request_transaction.base_request_id)
           worksheet.write(row, 9, (request_transaction.amount_paid.to_i rescue 0), amount_format)
         end
         rt_stop_row = row
         worksheet.write(row += 1, 1, "Total #{program ? program.name : program.id}")
         worksheet.write(row, 9, "=SUM(#{total_column_name}#{rt_start_row+1}:#{total_column_name}#{rt_stop_row+1})", sub_total_border_format)
         program_total_rows << row
       end
       worksheet.write(row += 1, 0, "Total #{Request.translate_grant_type(request_type).pluralize}", header_format)
       unless program_total_rows.empty?
         total_col_name = program_total_rows.map{|program_row| "#{total_column_name}#{program_row+1}"}.join(',')
         worksheet.write(row, 9, "=SUM(#{total_col_name})", sub_total_border_format)
       end
       request_type_total_rows << row
       row += 1 # Burn a row
     end
     worksheet.write(row += 1, 0, "Total", header_format)
     unless request_type_total_rows.empty?
       total_col_name = request_type_total_rows.map{|total_row| "#{total_column_name}#{total_row+1}"}.join(',')
       worksheet.write(row, 9, "=SUM(#{total_col_name})", sub_total_border_format)
     end
     
     workbook.close
     output.string
  end
end
