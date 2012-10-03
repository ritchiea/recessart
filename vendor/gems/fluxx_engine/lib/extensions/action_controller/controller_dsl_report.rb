class ActionController::ControllerDslReport < ActionController::ControllerDsl
  # name of the report, which should correspond to the name used in the directory of report classes
  attr_accessor :report_name_path
  # list of discovered reports for this report_name_path
  attr_accessor :reports
  
  def initialize controller_class, model_class = nil
    super model_class
    
    self.report_name_path = controller_class.name.gsub(/Controller$/, '').underscore.pluralize
    self.reports = []
  end
  
  
  # hunt down all report classes out there
  def load_report_classes
    reports = ActionController::ControllerDsl.controller_load_path.map do |controller_path|
      cur_dir = "#{controller_path}/reports/#{report_name_path}"
      if File.exist?(cur_dir) && File.directory?(cur_dir)
        Dir.entries(cur_dir).map do |report_file|
          if report_file =~ /\.rb$/
            require "#{cur_dir}/#{report_file}"
            report_class_name = report_file.titlecase.gsub(' ', '').gsub(/\.rb$/i, '')
            report_class = Kernel.const_get(report_class_name) rescue nil
            report_class if report_class && report_class <= ActionController::ReportBase
          end
        end
      end
    end.flatten.compact
  end
  
  # Automatically clears out the list of reports and rebuilds it
  def instantiate_reports
    self.reports = load_report_classes.sort_by{|rep| rep.get_order || 0}.map do |report_class|
      report_class.new(report_class.name.hash)
    end
  end
end
