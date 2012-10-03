module ReviewerBaseReport
  def base_compute_show_document_data controller, show_object, params, report_type=:export
    active_record_params = params[:active_record_base] || {}

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

    programs = params[:active_record_base][:program_id]
    programs = if params[:active_record_base][:program_id]
      Program.where(:id => params[:active_record_base][:program_id]).all rescue nil
    end || []
    programs = programs.compact

    lead_users = params[:active_record_base][:lead_user_ids]
    lead_users = if params[:active_record_base][:lead_user_ids]
      User.where(:id => params[:active_record_base][:lead_user_ids]).all rescue nil
    end || []
    lead_users = lead_users.compact

    reviews = 
      RequestReview.joins(:request).where([%{
        #{start_date ? " request_received_at >= '#{start_date.sql}' AND " : ''} 
        #{end_date ? " request_received_at <= '#{end_date.sql}' AND " : ''}
        requests.deleted_at IS NULL AND 
        granted = 0 AND
        requests.state not in (?) AND
        (1=? or requests.program_id in (?)) AND
        (1=? or requests.program_lead_id in (?))}, 
        Request.all_rejected_states,
        programs.empty?, programs,
        lead_users.empty?, lead_users
        ])
    user_ids = reviews.map(&:created_by_id).uniq
    request_ids = reviews.map(&:request_id).uniq
    users = User.where(:id => user_ids).order('last_name, first_name').all
    users_by_userid = users.inject({}) {|acc, user| acc[user.id] = user; acc}
    requests = Request.find_by_sql ["
    select requests.*, if(type = 'GrantRequest', (select name from organizations where id = program_organization_id), fip_title) grant_name,
    grant_begins_at begin_date,
    if(grant_begins_at is not null and duration_in_months is not null, date_add(date_add(grant_begins_at, INTERVAL duration_in_months month), interval -1 DAY), grant_begins_at) end_date
    from requests 
    where id in (?)", request_ids]
    requests_by_requestid = requests.inject({}) {|acc, request| acc[request.id] = request; acc}

    reviews_by_request_id = {}
    reviews_by_request_id = reviews.inject({}) do |acc, review|
      review_hash = acc[review.request_id] || {}
      acc[review.request_id] = review_hash
      review_hash[review.created_by_id] = review
      acc
    end

    output = StringIO.new

    workbook = WriteExcel.new(output)
    worksheet = workbook.add_worksheet

    non_wrap_bold_format, bold_format, header_format, solid_black_format, amount_format, number_format, date_format, text_format, header_format, 
        sub_total_format, sub_total_border_format, total_format, total_border_format, final_total_format, final_total_border_format, 
        bold_total_format, double_total_format = build_formats(workbook)
    # Add page summary
    # worksheet.write(0, 0, 'The Energy Foundation', non_wrap_bold_format)
    worksheet.write(1, 0, 'Reviewer Feedback', non_wrap_bold_format)
    worksheet.write(2, 0, 'Start Date: ' + start_date.mdy)
    worksheet.write(3, 0, 'End Date: ' + end_date.mdy)
    worksheet.write(4, 0, "Report Date: " + Time.now.mdy)
  
    # Adjust column widths
    worksheet.set_column(0, 9, 10)
    worksheet.set_column(1, 1, 15)
    worksheet.set_column(7, 7, 20)
    worksheet.set_column(9, 9, 15)
    column_letters = calculate_column_letters
  
  
    row_start = 6
    row = row_start

    if report_type == :feedback
      ["Grant Name", "Grant ID", "Amount Requested", "Amount Recommended", "Start Date", "End Date", "Duration"].
        each_with_index{|label, index| worksheet.write(6, index, label, header_format)}

      users.each_with_index do |user, index|
        worksheet.write(6, index + 7, user.first_name + ' ' + user.last_name, header_format)
      end
      worksheet.write(6, users.size + 7, 'Average', header_format)

      request_ids.each do |request_id|
        column=0
        request = requests_by_requestid[request_id]
    
        worksheet.write(row += 1, column, request.grant_name)
        worksheet.write(row, column += 1, request.base_request_id)
        worksheet.write(row, column += 1, (request.amount_requested.to_i rescue 0), amount_format)
        worksheet.write(row, column += 1, (request.amount_recommended.to_i rescue 0), amount_format)
        worksheet.write(row, column += 1, (request.begin_date ? (Time.parse(request.begin_date).mdy rescue '') : ''), date_format)
        worksheet.write(row, column += 1, (request.end_date ? (Time.parse(request.end_date).mdy rescue '') : ''), date_format)
        worksheet.write(row, column += 1, request.duration_in_months, number_format)
    
        start_user_column = column + 1
        users.each do |user|
          review = reviews_by_request_id[request_id]
          user_review = review[user.id.to_s] if review
          worksheet.write(row, column += 1, (user_review ? (user_review.rating.to_i rescue '') : ''), number_format)
        end
        end_user_column = column
    
        avg_formula = "#{column_letters[start_user_column]}#{row+1}:#{column_letters[end_user_column]}#{row+1}"
        worksheet.write(row, column+=1, ("=AVERAGE(#{avg_formula})"), number_format)
      end
    elsif report_type == :export
      
      ["Grant Name", "Grant ID", I18n.t(:program_name), "Amount Requested", "Amount Recommended", "Start Date", "End Date", "Duration", "Reviewer Name", "Rating", "Review Type", "Comment", "Benefits", "Outcomes", "Merits", "Recommendation"].
        each_with_index{|label, index| worksheet.write(6, index, label, header_format)}
      
      program_hash = Program.all.inject({}) {|acc, program| acc[program.id] = program; acc}
      reviews.each do |review|
        request_id = review.request_id
        column=0
        request = requests_by_requestid[request_id]

        worksheet.write(row += 1, column, request.grant_name)
        worksheet.write(row, column += 1, request.base_request_id)
        program = program_hash[request.program_id]
        worksheet.write(row, column += 1, program ? program.name : nil)
        worksheet.write(row, column += 1, (request.amount_requested.to_i rescue 0), amount_format)
        worksheet.write(row, column += 1, (request.amount_recommended.to_i rescue 0), amount_format)
        worksheet.write(row, column += 1, (request.begin_date ? (Time.parse(request.begin_date).mdy rescue '') : ''), date_format)
        worksheet.write(row, column += 1, (request.end_date ? (Time.parse(request.end_date).mdy rescue '') : ''), date_format)
        worksheet.write(row, column += 1, request.duration_in_months, number_format)

        user = users_by_userid[review.created_by_id]
        worksheet.write(row, column += 1, user ? user.full_name : nil)
        worksheet.write(row, column += 1, review.rating, number_format)
        worksheet.write(row, column += 1, review.review_type)
        worksheet.write(row, column += 1, review.comment)
        worksheet.write(row, column += 1, review.benefits)
        worksheet.write(row, column += 1, review.outcomes)
        worksheet.write(row, column += 1, review.merits)
        worksheet.write(row, column += 1, review.recommendation)
        
      end
    end  

    workbook.close
    output.string
  end
end