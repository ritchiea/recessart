module FluxxRequestTransactionFundingSourcesController
  ICON_STYLE = 'style-request-transaction-funding-sources'
  def self.included(base)
    base.insta_index RequestTransactionFundingSource do |insta|
      insta.template = 'request_transaction_funding_source_list'
      insta.filter_title = "RequestTransactionFundingSources Filter"
      insta.filter_template = 'request_transaction_funding_sources/request_transaction_funding_source_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show RequestTransactionFundingSource do |insta|
      insta.template = 'request_transaction_funding_source_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new RequestTransactionFundingSource do |insta|
      insta.template = 'request_transaction_funding_source_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit RequestTransactionFundingSource do |insta|
      insta.template = 'request_transaction_funding_source_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post RequestTransactionFundingSource do |insta|
      insta.template = 'request_transaction_funding_source_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put RequestTransactionFundingSource do |insta|
      insta.template = 'request_transaction_funding_source_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete RequestTransactionFundingSource do |insta|
      insta.template = 'request_transaction_funding_source_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related RequestTransactionFundingSource do |insta|
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