class MonthlyGrantsCountReport < ActionController::ReportBase
  include MonthlyGrantsBaseReport
  set_type_as_index
  def report_label
    "Monthly Grants By #{I18n.t(:program_name)}"
  end
  def compute_index_plot_data controller, index_object, params, models
    hash = by_month_report models.map(&:id), params, :count
    hash[:title] = report_label
    hash.to_json
  end
end
