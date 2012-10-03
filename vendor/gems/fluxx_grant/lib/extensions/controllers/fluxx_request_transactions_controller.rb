module FluxxRequestTransactionsController
  ICON_STYLE = 'style-transactions'
  def self.included(base)
    base.insta_index RequestTransaction do |insta|
      insta.template = 'request_transaction_list'
      insta.filter_title = "Transactions Filter"
      insta.filter_template = 'request_transactions/request_transaction_filter'
      insta.order_clause = 'due_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show RequestTransaction do |insta|
      insta.template = 'request_transaction_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.post do |triple|
        controller_dsl, model, outcome = triple
        # You should not be able to edit or delete transactions
        instance_variable_set '@edit_enabled', @edit_enabled || current_user.is_admin?
        instance_variable_set '@delete_enabled', current_user.is_admin?
      end
    end
    base.insta_new RequestTransaction do |insta|
      insta.template = 'request_transaction_form'
      insta.icon_style = ICON_STYLE
      insta.pre do |conf|
        request = Request.safe_find(grab_param(:request_transaction, :request_id))
        self.pre_model = RequestTransaction.new(:request => request)
      end
    end
    base.insta_edit RequestTransaction do |insta|
      insta.template = 'request_transaction_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post RequestTransaction do |insta|
      insta.template = 'request_transaction_form'
      insta.icon_style = ICON_STYLE
      insta.pre do |conf|
        self.pre_model = conf.load_new_model params
        populate_request_transaction_funding_source_param_hash self.pre_model
      end
    end
    base.insta_put RequestTransaction do |insta|
      insta.template = 'request_transaction_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.pre do |conf|
        self.pre_model = conf.load_existing_model params
        populate_request_transaction_funding_source_param_hash self.pre_model
      end
    end
    base.insta_delete RequestTransaction do |insta|
      insta.template = 'request_transaction_form'
      insta.icon_style = ICON_STYLE
    end

    base.insta_related RequestTransaction do |insta|
      insta.add_related do |related|
        related.display_name = 'People'
        related.for_search do |model|
          model.related_users
        end
        related.add_title_block do |model|
          model.full_name if model
        end
        related.display_template = '/users/related_users'
      end
      insta.add_related do |related|
        related.display_name = 'Orgs'
        related.for_search do |model|
          model.related_organizations
        end
        related.add_title_block do |model|
          model.name if model
        end
        related.display_template = '/organizations/related_organization'
      end
      insta.add_related do |related|
        related.display_name = 'Grants'
        related.for_search do |model|
          model.related_grants
        end
        related.add_title_block do |model|
          model.title if model
        end
        related.add_model_url_block do |model|
          send :granted_request_path, :id => model.id
        end
        related.display_template = '/grant_requests/related_request'
      end
      insta.add_related do |related|
        related.display_name = 'Trans'
        related.for_search do |model|
          model.related_transactions
        end
        related.add_title_block do |model|
          model.title if model
        end
        related.display_template = '/request_transactions/related_request_transactions'
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
    def populate_request_transaction_funding_source_param_hash model
      if model && params[:request_transaction] && params[:request_transaction][:using_transaction_form] == '1'
        # For newly created request transactions, the request is not yet populated
        if model.request_id && (model.request = Request.find model.request_id rescue nil)
          rfs_hash = model.request.request_funding_sources.inject({}) do |acc, rfs|
            amount = params["funding_source_value_#{rfs.id}"]
            amount = nil if amount.blank?
            if model.new_record?
              rtfs = RequestTransactionFundingSource.new(:request_transaction_id => nil, :request_funding_source_id => rfs.id)
            else
              rtfs = RequestTransactionFundingSource.where(:request_transaction_id => model.id, :request_funding_source_id => rfs.id).last || RequestTransactionFundingSource.create(:request_transaction_id => model.id, :request_funding_source_id => rfs.id)
            end
            acc[rtfs] = amount
            acc
          end
          model.request_transaction_funding_source_param_hash = rfs_hash
        end
      end
    end
  end
end