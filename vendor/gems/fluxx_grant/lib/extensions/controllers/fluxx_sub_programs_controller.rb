module FluxxSubProgramsController
  ICON_STYLE = 'style-admin-cards'
  def self.included(base)
    base.insta_index SubProgram do |insta|
      insta.template = 'sub_program_list'
      insta.filter_title = "Filter"
      insta.filter_template = 'sub_programs/sub_program_filter'
      insta.order_clause = 'name asc'
      insta.search_conditions = (lambda do |params, controller_dsl, controller|
        if params[:sub_program] && params[:sub_program][:not_retired]
          '(sub_programs.retired is null or sub_programs.retired = 0)'
        end
      end)
      insta.icon_style = ICON_STYLE
    end
    base.insta_show SubProgram do |insta|
      insta.template = 'sub_program_show'
      insta.footer_template = 'admin_cards/admin_footer'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new SubProgram do |insta|
      insta.template = 'sub_program_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit SubProgram do |insta|
      insta.template = 'sub_program_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post SubProgram do |insta|
      insta.template = 'sub_program_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put SubProgram do |insta|
      insta.template = 'sub_program_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete SubProgram do |insta|
      insta.template = 'sub_program_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related SubProgram do |insta|
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