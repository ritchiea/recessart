module FluxxMultiElementValuesController
  ICON_STYLE = 'style-multi-element-values'
  def self.included(base)
    base.insta_index MultiElementValue do |insta|
      insta.template = 'multi_element_value_list'
      insta.filter_title = "MultiElementValues Filter"
      insta.filter_template = 'multi_element_values/multi_element_value_filter'
      insta.order_clause = 'value, description'
      insta.results_per_page = 500
      insta.icon_style = ICON_STYLE
    end
    base.insta_show MultiElementValue do |insta|
      insta.template = 'multi_element_value_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new MultiElementValue do |insta|
      insta.template = 'multi_element_value_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit MultiElementValue do |insta|
      insta.template = 'multi_element_value_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post MultiElementValue do |insta|
      insta.template = 'multi_element_value_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put MultiElementValue do |insta|
      insta.template = 'multi_element_value_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete MultiElementValue do |insta|
      insta.template = 'multi_element_value_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related MultiElementValue do |insta|
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