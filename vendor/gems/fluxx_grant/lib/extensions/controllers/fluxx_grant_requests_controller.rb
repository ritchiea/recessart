module FluxxGrantRequestsController
  ICON_STYLE = 'style-grant-requests'
  def self.included(base)
    base.send :include, FluxxCommonRequestsController
    base.insta_index Request do |insta|
      insta.search_conditions = {:granted => 0, :has_been_rejected => 0}
      insta.template = 'grant_request_list'
      insta.suppress_model_anchor_tag = true
      insta.filter_title = "Requests Filter"
      insta.filter_template = 'grant_requests/grant_request_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
      insta.delta_type = GrantRequestsController.translate_delta_type false # Vary the request type based on whether a request has been granted yet or not
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          grant_request_index_format_html controller_dsl, outcome, default_block
        end
      end
    end
    base.insta_show GrantRequest do |insta|
      insta.template = 'grant_request_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.format do |format|
        format.html do |triple|
          if @model and @model.granted?
            redirect_params = params.delete_if{|k,v| %w[controller action].include?(k) }
            head 201, :location => (granted_request_path(redirect_params))
          else
            controller_dsl, outcome, default_block = triple
            grant_request_show_format_html controller_dsl, outcome, default_block
          end
        end
      end
      insta.post do |triple|
        controller_dsl, model, outcome = triple
        set_enabled_variables controller_dsl
      end
    end
    base.insta_new GrantRequest do |insta|
      insta.template = 'grant_request_form'
      insta.icon_style = ICON_STYLE
      insta.pre_create_model = true
    end
    base.insta_edit GrantRequest do |insta|
      insta.template = 'grant_request_form'
      insta.template_map = { :amend => "grant_request_amend_form" }
      insta.icon_style = ICON_STYLE
      insta.pre_create_model = true
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          grant_request_edit_format_html controller_dsl, outcome, default_block
        end
      end
      
    end
    base.insta_post GrantRequest do |insta|
      insta.template = 'grant_request_form'
      insta.icon_style = ICON_STYLE
      insta.pre_create_model = true
    end
    base.insta_put GrantRequest do |insta|
      insta.template = 'grant_request_form'
      insta.template_map = { :amend => "grant_request_amend_form" }
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.pre_create_model = true
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          grant_request_update_format_html controller_dsl, outcome, default_block
        end
      end
    end
    base.insta_delete GrantRequest do |insta|
      insta.template = 'grant_request_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related GrantRequest do |insta|      
      insta.add_related do |related|
        related.display_name = 'People'
        related.add_title_block do |model|
          model.full_name if model
        end
        related.for_search do |model|
          model.related_users
        end
        related.display_template = '/users/related_users'
      end
      insta.add_related do |related|
        related.display_name = 'Orgs'
        related.add_title_block do |model|
          model.name if model
        end
        related.for_search do |model|
          model.related_organizations
        end
        related.display_template = '/organizations/related_organization'
      end
      insta.add_related do |related|
        related.display_name = 'Projects'
        related.add_title_block do |model|
          model.title if model
        end
        related.for_search do |model|
          model.related_projects
        end
        related.display_template = '/projects/related_project'
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
