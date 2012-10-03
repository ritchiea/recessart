module FluxxProjectListItemsController
  def self.included(base)
    base.insta_index ProjectListItem do |insta|
      insta.template = 'project_list_item_list'
      insta.suppress_model_iteration = true
    end
    base.insta_show ProjectListItem do |insta|
      insta.template = 'project_list_item_show'
    end
    base.insta_post ProjectListItem do |insta|
      insta.template = 'project_list_item_form'
    end
    base.insta_delete ProjectListItem do |insta|
      insta.template = 'project_list_item_form'
    end
    base.insta_new ProjectListItem do |insta|
      insta.template = 'project_list_item_form'
    end
    base.insta_edit ProjectListItem do |insta|
      insta.template = 'project_list_item_form'
    end
    base.insta_put ProjectListItem do |insta|
      insta.template = 'project_list_item_form'
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