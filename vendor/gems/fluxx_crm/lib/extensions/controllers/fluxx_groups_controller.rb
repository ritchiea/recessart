module FluxxGroupsController
  ICON_STYLE = 'style-admin-cards'
  def self.included(base)
    base.insta_index Group do |insta|
      insta.template = 'group_list'
      insta.filter_title = "Groups Filter"
      insta.filter_template = 'groups/group_filter'
      insta.order_clause = 'name asc'
      insta.icon_style = ICON_STYLE
      insta.search_conditions = (lambda do |params, controller_dsl, controller|
        if params[:group] && params[:group][:not_retired]
          '(groups.deprecated is null or groups.deprecated = 0)'
        end
      end)
    end
    base.insta_show Group do |insta|
      insta.template = 'group_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new Group do |insta|
      insta.template = 'group_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit Group do |insta|
      insta.template = 'group_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post Group do |insta|
      insta.template = 'group_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put Group do |insta|
      insta.template = 'group_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete Group do |insta|
      insta.template = 'group_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related Group do |insta|
      insta.add_related do |related|
      end
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