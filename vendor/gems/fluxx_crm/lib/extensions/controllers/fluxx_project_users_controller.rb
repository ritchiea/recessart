module FluxxProjectUsersController
  def self.included(base)
    base.insta_index ProjectUser do |insta|
      insta.template = 'project_user_list'
      insta.suppress_model_iteration = true
    end
    base.insta_show ProjectUser do |insta|
      insta.template = 'project_user_show'
    end
    base.insta_post ProjectUser do |insta|
      insta.template = 'project_user_form'
    end
    base.insta_delete ProjectUser do |insta|
      insta.template = 'project_user_form'
    end
    base.insta_new ProjectUser do |insta|
      insta.template = 'project_user_form'
    end
    base.insta_edit ProjectUser do |insta|
      insta.template = 'project_user_form'
    end
    base.insta_put ProjectUser do |insta|
      insta.template = 'project_user_form'
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