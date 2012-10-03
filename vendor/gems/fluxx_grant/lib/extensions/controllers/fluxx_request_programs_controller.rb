module FluxxRequestProgramsController
  ICON_STYLE = 'style-request-programs'
  def self.included(base)
    base.insta_index RequestProgram do |insta|
      insta.template = 'request_program_list'
      insta.filter_title = "RequestPrograms Filter"
      insta.filter_template = 'request_programs/request_program_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show RequestProgram do |insta|
      insta.template = 'request_program_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new RequestProgram do |insta|
      insta.template = 'request_program_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit RequestProgram do |insta|
      insta.template = 'request_program_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post RequestProgram do |insta|
      insta.template = 'request_program_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put RequestProgram do |insta|
      insta.template = 'request_program_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete RequestProgram do |insta|
      insta.template = 'request_program_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related RequestProgram do |insta|
      insta.add_related do |related|
      end
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