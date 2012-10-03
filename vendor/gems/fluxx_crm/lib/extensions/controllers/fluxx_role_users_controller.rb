module FluxxRoleUsersController
  def self.included(base)
    base.insta_index RoleUser do |insta|
      insta.template = 'role_user_list'
    end
    base.insta_show RoleUser do |insta|
      insta.template = 'role_user_show'
    end
    base.insta_new RoleUser do |insta|
      insta.template = 'role_user_form'
    end
    base.insta_edit RoleUser do |insta|
      insta.template = 'role_user_form'
    end
    base.insta_post RoleUser do |insta|
      insta.template = 'role_user_form'
    end
    base.insta_put RoleUser do |insta|
      insta.template = 'role_user_form'
    end
    base.insta_delete RoleUser do |insta|
      insta.template = 'role_user_form'
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