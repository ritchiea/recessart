module FluxxMultiElementGroupsController
  extend FluxxModuleHelper

  ICON_STYLE = 'style-multi-element-groups'
  
  when_included do
    insta_index MultiElementGroup do |insta|
      insta.template = 'multi_element_group_list'
      insta.filter_title = "MultiElementGroups Filter"
      insta.filter_template = 'multi_element_groups/multi_element_group_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    insta_show MultiElementGroup do |insta|
      insta.template = 'multi_element_group_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    insta_edit MultiElementGroup do |insta|
      insta.template = 'multi_element_group_form'
      insta.icon_style = ICON_STYLE
    end
    insta_put MultiElementGroup do |insta|
      insta.template = 'multi_element_group_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    insta_delete MultiElementGroup do |insta|
      insta.template = 'multi_element_group_form'
      insta.icon_style = ICON_STYLE
    end
    insta_related MultiElementGroup do |insta|
      insta.add_related do |related|
      end
    end
  end

  class_methods do
  end

  instance_methods do
  end
end
