require 'writeexcel'
class ActionController::ReportBase
  include ActionView::Helpers::NumberHelper
  # unique identifier for this report
  attr_accessor :report_id
  # label for this report
  attr_accessor :report_label
  # description for this report
  attr_accessor :report_description
  # report type; list or show
  attr_accessor :report_type
  # template path for rendering the page that displays the plot; nil will just use the default
  attr_accessor :plot_template
  # template path for rendering the filter; nil would suggest that there is no filter to be supplied
  attr_accessor :filter_template
  # footer template path for rendering the report footer; nil will just use the default
  attr_accessor :plot_template_footer

  def initialize report_id
    self.report_id = report_id
  end

  def self.set_type_as_show
    @report_type = :show
  end

  def self.set_type_as_index
    @report_type = :index
  end

  def self.set_order order
    @order = order
  end

  def self.get_order
    @order
  end

  def self.is_show?
    @report_type == :show
  end

  def self.is_index?
    @report_type == :index
  end

  def self.report_has_plot?
    self.is_show? && self.public_method_defined?(:compute_show_plot_data) ||
      self.is_index? && self.public_method_defined?(:compute_index_plot_data)
  end
  def has_plot?
    self.class.report_has_plot?
  end
  def self.report_has_document?
    self.is_show? && self.public_method_defined?(:compute_show_document_data) && self.public_method_defined?(:compute_show_document_headers) ||
      self.is_index? && self.public_method_defined?(:compute_index_document_data) && self.public_method_defined?(:compute_index_document_headers)
  end
  def has_document?
    self.class.report_has_document?
  end

  # optional descrition for this report
  def report_description controller, index_object, params, *models
  end
  # optional text describing aspects of the filter for this report, example: date range
  def report_filter_text controller, index_object, params, *models
  end
  # optional legend for this report
  def report_legend controller, index_object, params, *models
    [{}]
  end
  # optional summary for this report
  def report_summary controller, index_object, params, *models
  end
  
  def build_formats workbook
    # Set up some basic formats:
    non_wrap_bold_format = workbook.add_format()
    non_wrap_bold_format.set_bold()
    non_wrap_bold_format.set_valign('top')
    bold_format = workbook.add_format()
    bold_format.set_bold()
    bold_format.set_align('center')
    bold_format.set_valign('top')
    bold_format.set_text_wrap()
    header_format = workbook.add_format()
    header_format.set_bold()
    header_format.set_bottom(1)
    header_format.set_align('top')
    header_format.set_text_wrap()
    solid_black_format = workbook.add_format()
    solid_black_format.set_bg_color('black')
    amount_format = workbook.add_format()
    amount_format.set_num_format("#{I18n.t 'number.currency.format.unit'}#,##0")
    amount_format.set_valign('bottom')
    amount_format.set_text_wrap()
    number_format = workbook.add_format()
    number_format.set_num_format(0x01)
    number_format.set_valign('bottom')
    number_format.set_text_wrap()
    date_format = workbook.add_format()
    date_format.set_num_format(15)
    date_format.set_valign('bottom')
    date_format.set_text_wrap()
    text_format = workbook.add_format()
    text_format.set_valign('top')
    text_format.set_text_wrap()
    
    bold_total_format = workbook.add_format()
    bold_total_format.set_bold()
    bold_total_format.set_top(2)
    bold_total_format.set_num_format(0x03)
    
    double_total_format = workbook.add_format()
    double_total_format.set_bold()
    double_total_format.set_top(6)
    double_total_format.set_num_format(0x03)
    
    header_format = workbook.add_format(
      :bold => 1,
      :color => 9,
      :bg_color => 8)
    workbook.set_custom_color(40, 214, 214, 214)
    sub_total_format = workbook.add_format(
      :bold => 1,
      :color => 8,
      :bg_color => 40)
    sub_total_border_format = workbook.add_format(
       :top => 1,
       :bold => 1,
       :num_format => "#{I18n.t 'number.currency.format.unit'}#,##0",
       :color => 8,      
       :bg_color => 40)      
    total_format = workbook.add_format(
      :bold => 1,
      :color => 8,
      :bg_color => 22)
    total_border_format = workbook.add_format(
      :top => 1,
      :bold => 1,
      :num_format => "#{I18n.t 'number.currency.format.unit'}#,##0",
      :color => 8,
      :bg_color => 22)
    workbook.set_custom_color(41, 128, 128, 128)      
    final_total_format = workbook.add_format(
      :bold => 1,
      :color => 8,
      :bg_color => 41)
    final_total_border_format = workbook.add_format(
      :top => 1,
      :bold => 1,
      :num_format => "#{I18n.t 'number.currency.format.unit'}#,##0",
      :color => 8,
      :bg_color => 41)
    [non_wrap_bold_format, bold_format, header_format, solid_black_format, amount_format, number_format, date_format, text_format, header_format, 
        sub_total_format, sub_total_border_format, total_format, total_border_format, final_total_format, final_total_border_format, bold_total_format, double_total_format
    ]
  end
  
  def calculate_column_letters
    # Calculate letter combinations for column names for the sake of formulas; A, B, C, .. Z, AB, AC, ... ZZ
    column_letters = ('A'..'Z').to_a
    column_letters = column_letters + column_letters.map {|letter1| column_letters.map {|letter2| letter1 + letter2 } }
    column_letters.flatten
  end
  
  # implement methods such as:
  # INDEX:
  # compute_index_plot_data controller, index_object, params, models
  #   * should return a string that contains JSON, etc. to render and be used to draw the chart
  # compute_index_document_headers controller, index_object, params, models
  #   * should return an array of the [filename, content-type]
  # compute_index_document_data controller, index_object, params, models
  #   * should return a string that contains the document to be sent to the browser
  # OR SHOW:
  # compute_show_plot_data controller, index_object, params
  #   * should return a string that contains JSON, etc. to render and be used to draw the chart
  # compute_show_document_headers controller, index_object, params, models
  #   * should return an array of the [filename, content-type]
  # compute_show_document_data controller, index_object, params
  #   * should return a string that contains the document to be sent to the browser
  # BUT NOT BOTH


end
