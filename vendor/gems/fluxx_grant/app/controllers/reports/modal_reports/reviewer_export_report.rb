class ReviewerExportReport < ActionController::ReportBase
  include ReviewerBaseReport
  set_type_as_show

  def initialize report_id
    super report_id
    self.filter_template = 'modal_reports/reviewer_export_filter'
  end

  def report_label
    'Reviewer Export Report'
  end

  def report_description
    'External Reviewer Export (Excel Table)'
  end

  def compute_show_document_headers controller, show_object, params
    ['fluxx_' + 'reviewer_export' + '_' + Time.now.strftime("%m%d%y") + ".xls", 'application/vnd.ms-excel']
  end

  def compute_show_document_data controller, show_object, params
    base_compute_show_document_data controller, show_object, params, :export
  end
end