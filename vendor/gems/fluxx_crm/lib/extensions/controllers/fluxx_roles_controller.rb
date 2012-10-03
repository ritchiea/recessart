module FluxxRolesController
  ICON_STYLE = 'style-roles'
  def self.included(base)
    base.insta_index Role do |insta|
      insta.template = 'role_list'
      insta.filter_title = "Roles Filter"
      insta.filter_template = 'roles/role_filter'
      insta.order_clause = 'name asc, updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show Role do |insta|
      insta.template = 'role_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new Role do |insta|
      insta.template = 'role_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit Role do |insta|
      insta.template = 'role_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post Role do |insta|
      insta.template = 'role_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put Role do |insta|
      insta.template = 'role_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete Role do |insta|
      insta.template = 'role_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related Role do |insta|
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
