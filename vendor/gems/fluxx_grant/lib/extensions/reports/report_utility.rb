module ReportUtility
# Static function to help with SQL queries

 # TODO AML: Instead of assuming the Request object is available, just use the ActiveRecord class directly
 # TODO AML: Create a better hook for PRE_PIPELINE_STATES
 # TODO AML: Document each helper function
  PRE_PIPELINE_STATES = ['new', 'funding_recommended', 'rejected']

  # General helpers
  def self.pre_pipeline_states
    PRE_PIPELINE_STATES
  end

  def self.get_program_ids program_id_param, return_all_if_nil = true
    if (program_id_param)
      program_id_param.map {|program| program.to_i}
    elsif return_all_if_nil
      query = 'SELECT id FROM programs WHERE retired = 0'
      array_query([query], "id")
    else
      return []
    end
  end

  def self.query_map_to_array(query, array, map_field, result_field, convert_to_integer = true)
    req = Request.connection.execute(Request.send(:sanitize_sql, query))
    results = Array.new.fill(0, 0, array.length)
    req.each_hash do |res|
      i = array.index(res[map_field].to_i)
      if i
        results[i] = (convert_to_integer ? res[result_field].to_i : res[result_field])
      end
    end
    results
  end

  def self.array_query(query, result_field = "id", convert_to_integer = true)
    req = Request.connection.execute(Request.send(:sanitize_sql, query))
    results = []
    req.each_hash{ |res| results << (convert_to_integer ? res[result_field].to_i : res[result_field]) }
    return results
  end

  def self.single_value_query(query)
    req = Request.connection.execute(Request.send(:sanitize_sql, query))
    req.each_hash{ |res| return res}
  end
  def self.extract_ids(options)
    req = Request.connection.execute(Request.send(:sanitize_sql, options))
    ids = []
    req.each_hash{ |res| ids << res["id"].to_i }
    return ids
  end

  def self.get_xaxis(start_date, stop_date, category_only = true)
    i = 0
    get_months_and_years(start_date, stop_date).collect{ |date| category_only ? date[0].to_s + "/" + date[1].to_s : [i = i + 1, date[0].to_s + "/" + date[1].to_s] }
  end

  # Return query data with values for all months within a range
  def self.normalize_month_year_query(query, start_date, stop_date, result_field)
    req = Request.connection.execute(Request.send(:sanitize_sql, query))
    data = get_months_and_years(start_date, stop_date)
    req.each_hash do |row|
      i = data.index([row["month"].to_i, row["year"].to_i])
      data[i] << row[result_field]
    end
    data.collect { |point| point[2].to_i }
  end

  def self.get_months_and_years(start_date, stop_date)
   (start_date..stop_date).collect { |date| [date.month, date.year] }.uniq
  end

  def self.get_years(start_date, stop_date)
   (start_date..stop_date).collect { |date| date.year }.uniq
  end

  # Helpers specific to visualizations

  def self.get_report_totals request_ids
    hash = {}
    query = "select count(id) as num, sum(amount_recommended) as amount from requests r where id in (?) and type = (?)"
    res = ReportUtility.single_value_query([query, request_ids, "GrantRequest"])
    hash[:grants] = res["num"]
    hash[:grants_total] = res["amount"]
    res = ReportUtility.single_value_query([query, request_ids, "FipRequest"])
    hash[:fips] = res["num"]
    hash[:fips_total] = res["amount"]
    hash
  end
end