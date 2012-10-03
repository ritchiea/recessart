module FluxxProjectRequestsController
  def self.included(base)
    base.insta_index ProjectRequest do |insta|
      insta.template = 'project_request_list'
      insta.suppress_model_iteration = true
    end
    base.insta_show ProjectRequest do |insta|
      insta.template = 'project_request_show'
    end
    base.insta_post ProjectRequest do |insta|
      insta.template = 'project_request_form'
    end
    base.insta_delete ProjectRequest do |insta|
      insta.template = 'project_request_form'
    end
    base.insta_new ProjectRequest do |insta|
      insta.template = 'project_request_form'
    end
    base.insta_edit ProjectRequest do |insta|
      insta.template = 'project_request_form'
    end
    base.insta_put ProjectRequest do |insta|
      insta.template = 'project_request_form'
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