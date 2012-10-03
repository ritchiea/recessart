module FluxxProjectOrganizationsController
  def self.included(base)
    base.insta_index ProjectOrganization do |insta|
      insta.template = 'project_organization_list'
      insta.suppress_model_iteration = true
    end
    base.insta_show ProjectOrganization do |insta|
      insta.template = 'project_organization_show'
    end
    base.insta_post ProjectOrganization do |insta|
      insta.template = 'project_organization_form'
    end
    base.insta_delete ProjectOrganization do |insta|
      insta.template = 'project_organization_form'
    end
    base.insta_new ProjectOrganization do |insta|
      insta.template = 'project_organization_form'
    end
    base.insta_edit ProjectOrganization do |insta|
      insta.template = 'project_organization_form'
    end
    base.insta_put ProjectOrganization do |insta|
      insta.template = 'project_organization_form'
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