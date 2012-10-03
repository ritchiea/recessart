module FluxxUserPermissionsController
  ICON_STYLE = 'style-user-permissions'
  def self.included(base)
    base.insta_index UserPermission do |insta|
      insta.template = 'user_permission_list'
      insta.filter_title = "UserPermissions Filter"
      insta.filter_template = 'user_permissions/user_permission_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show UserPermission do |insta|
      insta.template = 'user_permission_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new UserPermission do |insta|
      insta.template = 'user_permission_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit UserPermission do |insta|
      insta.template = 'user_permission_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post UserPermission do |insta|
      insta.template = 'user_permission_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put UserPermission do |insta|
      insta.template = 'user_permission_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete UserPermission do |insta|
      insta.template = 'user_permission_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related UserPermission do |insta|
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