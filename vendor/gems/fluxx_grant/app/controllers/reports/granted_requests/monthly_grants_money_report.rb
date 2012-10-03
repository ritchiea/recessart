class MonthlyGrantsMoneyReport < ActionController::ReportBase
  include MonthlyGrantsBaseReport
  set_type_as_index

  def report_label
    "Grant #{CurrencyHelper.current_long_name.pluralize} By Month"
  end

  def compute_index_plot_data controller, index_object, params, models
    hash = by_month_report models.map(&:id), params, :sum_amount
    hash[:title] = report_label
    hash.to_json
  end
end
