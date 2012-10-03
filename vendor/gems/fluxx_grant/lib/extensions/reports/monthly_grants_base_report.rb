module MonthlyGrantsBaseReport

  attr_accessor :start_date, :end_date

  def report_filter_text controller, index_object, params, models
    if (self.start_date && self.end_date)
      "#{self.start_date.strftime("%B %d, %Y")} to #{self.end_date.strftime("%B %d, %Y")}"
    end
  end

  def report_summary controller, index_object, params, models
    hash = ReportUtility.get_report_totals models.map(&:id)
    "#{hash[:grants]} Grants totaling #{number_to_currency(hash[:grants_total])} and #{hash[:fips]} #{I18n.t(:fip_name).pluralize} totaling #{number_to_currency(hash[:fips_total])}"
  end

  def report_legend controller, index_object, params, models
    request_ids = models.map(&:id)
    subquery = "SELECT amount_recommended, id FROM requests WHERE type = ? and id in (?)"
    query = "SELECT programs.name AS program, programs.id as program_id, count(grants.id) as grants, sum(grants.amount_recommended) as grant_dollars, count(fips.id) as fips, sum(fips.amount_recommended) as fip_dollars FROM requests LEFT JOIN programs ON programs.id = requests.program_id LEFT JOIN (#{subquery}) as grants ON grants.id = requests.id LEFT JOIN (#{subquery}) as fips ON fips.id = requests.id WHERE requests.id IN (?) GROUP BY requests.program_id ORDER BY program DESC"
    req = Request.connection.execute(Request.send(:sanitize_sql, [query, "GrantRequest", request_ids, "FipRequest", request_ids, request_ids]))
    legend = [{ :table => ["Program", "Grants", "Grant #{CurrencyHelper.current_long_name.pluralize}", I18n.t(:fip_name).pluralize, "#{I18n.t(:fip_name)} #{CurrencyHelper.current_long_name.pluralize} By Organizaton"], :filter => "", "listing_url".to_sym => "", "card_title".to_sym => ""}]
    filter = []
    params["request"].each do |key, value|
      next if key == "program_id"
      if value.is_a? Array
        value.each {|val| filter << "request[#{key}][]=#{val}"}
      else
        filter << "request[#{key}]=#{value}"
      end
    end if params["request"]
    req.each_hash do |result|
      legend << { :table => [result["program"], result["grants"], number_to_currency(result["grant_dollars"]), result["fips"], number_to_currency(result["fip_dollars"])],
        :filter =>  filter.join("&") + "&request[program_id][]=#{result['program_id']}",
        "listing_url".to_sym => controller.granted_requests_path, "card_title".to_sym => "#{result['program']} Grants"}
    end
   legend
  end

  def by_month_report request_ids, params, aggregate_type=:count
    plot = {:library => "jqplot"}
    plot[:title] = 'override this in the calling class...'
    plot[:seriesDefaults] = { :fill => true, :showMarker => true, :shadow => false }
    plot[:stackSeries] = true;
    plot[:series] = []
    plot[:data] = []

    xaxis = []
    data = []
    legend = []
    programs = []
    data = {}
    start_date = false
    end_date = false

    if aggregate_type == :sum_amount
      aggregate = "SUM(requests.amount_recommended)"
    else
      aggregate = "COUNT(requests.id)"
    end
    query = "select #{aggregate} as num, requests.grant_agreement_at as date, YEAR(requests.grant_agreement_at) as year, MONTH(requests.grant_agreement_at) as month, requests.program_id as program_id, programs.name as program 
      from requests left join programs on programs.id = requests.program_id where grant_agreement_at IS NOT NULL and requests.id in (?) group by requests.program_id, YEAR(grant_agreement_at), MONTH(grant_agreement_at) ORDER BY program"
    req = Request.connection.execute(Request.send(:sanitize_sql, [query, request_ids]))
    req.each_hash do |row|
      year = row["year"].to_i
      month = row["month"].to_i
      program_id = row["program_id"].to_i
      store_hash data, year, month, program_id, row["num"].to_i
      if !programs.find_index program_id
        programs << program_id
        plot[:series] << { :label => row["program"]}
      end
      date = Date.parse(row["date"])
      end_date = date if !end_date || date > end_date
      start_date = date if !start_date || date < start_date
    end
    filter = params["request"]
    if (!filter)
      filter = {}
    end
    start_date = Date.parse((filter["request_from_date"]).is_a?(Array) ? (filter["request_from_date"]).first : filter["request_from_date"]) if (!filter["request_from_date"].blank?)
    end_date = Date.parse((filter["request_to_date"]).is_a?(Array) ? (filter["request_to_date"]).first : filter["request_to_date"]) if (!filter["request_to_date"].blank?)
    
    start_date = Date.today if (!start_date)
    end_date = Date.today if (!end_date)

    # Store these calculated dates so we can use them in the filter text
    self.start_date = start_date
    self.end_date = end_date

    # We need a plot of more than one month to make sense
    if (start_date.month == end_date.month && start_date.year == end_date.year)
      end_date =self.end_date = self.end_date >> 1
    end
    i = 0
    max_grants = 0
    programs.each do |program_id|
      row = []
      ReportUtility.get_months_and_years(start_date, end_date).each do |date|
        if (program_id == programs.first)
          xaxis << date[0].to_s + "/" + date[1].to_s
          i = i + 1
        end
        grants = get_count(data, date[1], date[0], program_id)
        row << grants
        if (grants > max_grants)
          max_grants = grants
        end
      end
      plot[:data] << row
    end
    num_ticks = 14
    tick_at = xaxis.count / num_ticks
    if tick_at < 1
      tick_at = 1
    end
    axis = []
    xaxis.each_index do |x|
      if x == 0 || x % tick_at == 0
        axis << [x + 1, xaxis[x]]
      end
    end
    plot[:axes] = { :xaxis => { :min => 0, :max => i, :ticks => axis, :tickOptions => { :angle => -30 }}, :yaxis => { :min => 0, :tickOptions => {:formatString => aggregate_type == :sum_amount ? "#{I18n.t 'number.currency.format.unit'}%.2f" : '%d'}}}
    if plot[:data].count == 0
      plot[:data] << [0]
      plot.delete(:series)
      plot.delete(:axes)
    end
    plot
  end

  def store_hash data, year, month, program, number
    if !data[year]
      data[year] = {}
    end
    if !data[year][month]
      data[year][month] = {}
    end
    data[year][month][program] = number
  end

  def get_count data, year, month, program
    !data[year] || !data[year][month] || !data[year][month][program] ? 0 : data[year][month][program]
  end
end
