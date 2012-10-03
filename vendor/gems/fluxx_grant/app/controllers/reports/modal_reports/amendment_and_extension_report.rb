class AmendmentAndExtensionReport < ActionController::ReportBase
  set_type_as_show

  def initialize report_id
    super report_id
    self.filter_template = 'modal_reports/amendment_and_extension_filter' #'modal_reports/'
  end

  def report_label
    'Amendment & Extension Report'
  end

  def report_description
    'List of grants where amendment/extension updates to end-date or amount have been entered'
  end

  def compute_show_document_headers controller, show_object, params
    ['fluxx_' + 'amendment_and_extension' + '_' + Time.now.strftime("%m%d%y") + ".xls", 'application/vnd.ms-excel']
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
    
    request_amendments = RequestAmendment.
      select('request_amendments.*, original_ras.duration original_duration, original_ras.end_date original_end_date, 
        original_ras.amount_recommended original_amount_recommended, requests.grant_begins_at').
      joins('INNER JOIN requests ON request_id=requests.id').
      joins('LEFT OUTER JOIN request_amendments original_ras ON original_ras.request_id=requests.id and original_ras.original = 1').
      where('1=? OR requests.type IN (?)', query_types.empty?, query_types).
      where('1=? OR requests.program_id IN (?)', programs.empty?, programs).
      where('requests.grant_agreement_at > ? AND requests.grant_agreement_at < ?', start_date, end_date).
      where(:original => false).
      order('requests.id DESC, request_amendments.created_at ASC').
      all
    
    output = StringIO.new
    workbook = WriteExcel.new(output)
    worksheet = workbook.add_worksheet
     
    non_wrap_bold_format, bold_format, header_format, solid_black_format, amount_format, number_format, date_format, text_format, header_format, 
    sub_total_format, sub_total_border_format, total_format, total_border_format, final_total_format, final_total_border_format, 
    bold_total_format, double_total_format = build_formats(workbook)

    row = -1

    # Add page summary
    worksheet.write(row+=1, 0, 'Amendment & Extension Report', non_wrap_bold_format)
    worksheet.write(row+=1, 0, 'Start Date: ' + start_date.mdy)
    worksheet.write(row+=1, 0, 'End Date: ' + end_date.mdy)
    worksheet.write(row+=1, 0, "Report Date: " + Time.now.mdy)

    # Adjust column widths
    worksheet.set_column(0, 9, 10)
    worksheet.set_column(1, 1, 15)
    worksheet.set_column(7, 7, 20)
    worksheet.set_column(9, 9, 15)
    
    dont_use_duration_in_requests = Fluxx.config(:dont_use_duration_in_requests) == "1"

    columns = ["Grant ID", "Grant Name", "Fiscal Organization (If applicable)", "Start Date", dont_use_duration_in_requests ? "End Date (Original)" : 'Duration (Original)', "Amount Recommended (Original)",
     "Change Date (When record was altered)", dont_use_duration_in_requests ? "Adjusted End Date (If applicable)" : 'Duration (If applicable)', "Amended Amount (If applicable)"]

    row += 1
    columns.each_with_index { |label,index| worksheet.write(row, index, label, header_format) }

    request_amendments.each { |amendment|
      row += 1
      request = amendment.request

      if 
        amended_end_date = amendment.end_date
        original_end_date = amendment.original_end_date
      else
        amended_duration = amendment.duration
        original_duration = amendment.original_duration
      end

      worksheet.write(row, 0, request.grant_or_request_id)
      worksheet.write(row, 1, request.is_a?(FipRequest) ? request.fip_title : request.org_name_text)
      worksheet.write(row, 2, request.fiscal_organization ? request.fiscal_organization.name : "")
      worksheet.write(row, 3, request.grant_begins_at ? request.grant_begins_at.mdy : "", date_format)
      if dont_use_duration_in_requests
        worksheet.write(row, 4, original_end_date ? (Time.parse(original_end_date).mdy rescue nil) : nil, date_format)
      else
        worksheet.write(row, 4, original_duration ? (original_duration.to_i rescue nil) : nil, number_format)
      end
      worksheet.write(row, 5, (amendment.original_amount_recommended ? (amendment.original_amount_recommended.to_f rescue nil) : nil), amount_format)
      worksheet.write(row, 6, amendment.created_at ? amendment.created_at.mdy : "", date_format)
      if dont_use_duration_in_requests
        worksheet.write(row, 7, amended_end_date ? amended_end_date.mdy : "", date_format)
      else
        worksheet.write(row, 7, amended_duration ? (amended_duration.to_i rescue nil) : nil, number_format)
      end
      worksheet.write(row, 8, amendment.amount_recommended ? (amendment.amount_recommended.to_f rescue nil) : nil, amount_format)
    }

    workbook.close
    output.string
  end
end
