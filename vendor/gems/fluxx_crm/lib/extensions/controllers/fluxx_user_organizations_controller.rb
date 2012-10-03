module FluxxUserOrganizationsController
  def self.included(base)
    base.insta_index UserOrganization do |insta|
      insta.template = 'user_organization_list'
    end
    base.insta_show UserOrganization do |insta|
      insta.template = 'user_organization_show'
    end
    base.insta_new UserOrganization do |insta|
      insta.template = 'user_organization_form'
    end
    base.insta_edit UserOrganization do |insta|
      insta.template = 'user_organization_form'
    end
    base.insta_post UserOrganization do |insta|
      insta.template = 'user_organization_form'
    end
    base.insta_put UserOrganization do |insta|
      insta.template = 'user_organization_form'
    end
    base.insta_delete UserOrganization do |insta|
      insta.template = 'user_organization_form'
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