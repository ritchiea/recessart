module FluxxModulesController
  ICON_STYLE = 'style-modules'
  def self.included(base)
    base.insta_index Module do |insta|
      insta.template = 'module_list'
      insta.filter_title = "Modules Filter"
      insta.filter_template = 'modules/module_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show Module do |insta|
      insta.template = 'module_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new Module do |insta|
      insta.template = 'module_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit Module do |insta|
      insta.template = 'module_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post Module do |insta|
      insta.template = 'module_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put Module do |insta|
      insta.template = 'module_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete Module do |insta|
      insta.template = 'module_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related Module do |insta|
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