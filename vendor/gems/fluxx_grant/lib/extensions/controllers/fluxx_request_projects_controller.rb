module FluxxRequestProjectsController
  def self.included(base)
    base.insta_index ProjectRequest do |insta|
      insta.template = 'request_project_list'
      insta.search_conditions = lambda do |params, controller_dsl, controller|
        "request_id = #{params[:request_id].to_i}" if params[:request_id]
      end
    end
    base.insta_show ProjectRequest do |insta|
      insta.template = 'request_project_show'
    end
    base.insta_new ProjectRequest do |insta|
      insta.template = 'request_project_form'
    end
    base.insta_edit ProjectRequest do |insta|
      insta.template = 'request_project_form'
    end
    base.insta_post ProjectRequest do |insta|
      insta.template = 'request_project_form'
    end
    base.insta_put ProjectRequest do |insta|
      insta.template = 'request_project_form'
    end
    base.insta_delete ProjectRequest do |insta|
      insta.template = 'request_project_form'
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
