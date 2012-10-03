module FluxxWorkTasksController
  ICON_STYLE = 'style-work-tasks'
  def self.included(base)
    base.insta_index WorkTask do |insta|
      insta.template = 'work_task_list'
      insta.filter_title = "WorkTasks Filter"
      insta.filter_template = 'work_tasks/work_task_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show WorkTask do |insta|
      insta.template = 'work_task_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new WorkTask do |insta|
      insta.template = 'work_task_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit WorkTask do |insta|
      insta.template = 'work_task_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post WorkTask do |insta|
      insta.template = 'work_task_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put WorkTask do |insta|
      insta.template = 'work_task_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete WorkTask do |insta|
      insta.template = 'work_task_form'
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