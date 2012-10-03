module FluxxBudgetRequestsController
  ICON_STYLE = 'style-budget-requests'
  def self.included(base)
    base.insta_index BudgetRequest do |insta|
      insta.template = 'budget_request_list'
      insta.filter_title = "BudgetRequests Filter"
      insta.filter_template = 'budget_requests/budget_request_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show BudgetRequest do |insta|
      insta.template = 'budget_request_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new BudgetRequest do |insta|
      insta.template = 'budget_request_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit BudgetRequest do |insta|
      insta.template = 'budget_request_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post BudgetRequest do |insta|
      insta.template = 'budget_request_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put BudgetRequest do |insta|
      insta.template = 'budget_request_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete BudgetRequest do |insta|
      insta.template = 'budget_request_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related BudgetRequest do |insta|
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