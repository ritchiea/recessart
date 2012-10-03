module FluxxUsersController
  ICON_STYLE = 'style-users'
  def self.included(base)
    base.insta_index User do |insta|
      insta.template = 'user_list'
      insta.order_clause = 'last_name asc, first_name asc'
      insta.icon_style = ICON_STYLE
      insta.filter_template = 'users/user_filter'
      insta.order_clause = 'first_name asc, last_name asc'
    end
    base.insta_show User do |insta|
      insta.template = 'user_show'
      insta.icon_style = ICON_STYLE
    end
    base.insta_new User do |insta|
      insta.template = 'user_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit User do |insta|
      insta.template = 'user_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post User do |insta|
      insta.template = 'user_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put User do |insta|
      insta.template = 'user_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_delete User do |insta|
      insta.template = 'user_form'
      insta.icon_style = ICON_STYLE
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