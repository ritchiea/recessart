module FluxxModalReportsController
  ICON_STYLE = 'style-modal-reports'
  def self.included(base)
    base.insta_index do |insta|
      insta.template = 'modal_report_list'
      insta.filter_title = "ModalReports Filter"
      insta.icon_style = ICON_STYLE
      insta.always_skip_wrapper = true
      insta.pre do |controller_dsl|
        self.pre_models = insta_show_report_list
      end
    end
    base.insta_show do |insta|
      insta.template = 'modal_report_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end

    base.insta_report do |insta|
      insta.report_name_path = 'modal_reports'
    end

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
  end
end