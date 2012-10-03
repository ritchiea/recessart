module FluxxProjectListsController
  def self.included(base)
    base.insta_index ProjectList do |insta|
      insta.template = 'project_list_list'
      insta.suppress_model_iteration = true
    end
    base.insta_show ProjectList do |insta|
      insta.template = 'project_list_show'
    end
    base.insta_post ProjectList do |insta|
      insta.template = 'project_list_form'
    end
    base.insta_delete ProjectList do |insta|
      insta.template = 'project_list_form'
    end
    base.insta_new ProjectList do |insta|
      insta.template = 'project_list_form'
    end
    base.insta_edit ProjectList do |insta|
      insta.template = 'project_list_form'
    end
    base.insta_put ProjectList do |insta|
      insta.template = 'project_list_form'
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