module FluxxGrantedRequestsController
  ICON_STYLE = 'style-granted-requests'
  REPORT_ICON_STYLE = 'style-modal-reports'

  # Note that the granted requests controller is necessary to show a different look and feel for the index (filtering by granted), and for the show, which should have different related data
  def self.included(base)
    base.send :include, FluxxCommonRequestsController
    base.insta_index Request do |insta|
      insta.template = 'granted_requests/grant_request_list'
      insta.filter_title = "Grants Filter"
      insta.filter_template = 'granted_requests/granted_request_filter'
      insta.search_conditions = {:granted => 1, :has_been_rejected => 0}
      insta.suppress_model_anchor_tag = true
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
      insta.report_icon_style = REPORT_ICON_STYLE
      insta.delta_type = GrantedRequestsController.translate_delta_type true # Vary the request type based on whether a request has been granted yet or not
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          grant_request_index_format_html controller_dsl, outcome, default_block
        end
      end
    end
    base.insta_report do |insta|
      insta.report_name_path = 'granted_requests'
    end
    base.insta_edit Request do |insta|
      insta.force_redirect do |conf|
        # Load the model; we may have either a FIP or a Grant, handle both cases
        model = conf.load_existing_model params
        redirect_params = params.delete_if{|k,v| %w[controller action].include?(k) }
        head 201, :location => (send("edit_#{model.class.name.tableize.singularize}_path", model.id, redirect_params))
      end
    end
    base.insta_put Request do |insta|
      insta.template = 'grant_request_form'
      insta.template_map = { :amend => "grant_request_amend_form" }
      insta.icon_style = ICON_STYLE
      insta.report_icon_style = REPORT_ICON_STYLE
      insta.add_workflow
      insta.pre_create_model = true
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          grant_request_update_format_html controller_dsl, outcome, default_block
        end
      end
    end
    
    base.insta_show Request do |insta|
      insta.template = 'grant_requests/grant_request_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          grant_request_show_format_html controller_dsl, outcome, default_block
        end
      end
      insta.post do |triple|
        controller_dsl, model, outcome = triple
        set_enabled_variables controller_dsl
      end
    end
    base.insta_delete Request do |insta|
      insta.template = 'grant_request_form'
      insta.icon_style = ICON_STYLE
      insta.report_icon_style = REPORT_ICON_STYLE
    end
    
    base.insta_related Request do |insta|
      insta.add_related do |related|
        related.display_name = 'People'
        related.show_tab? do |args|
          controller, model = args
          controller.current_user.has_view_for_model? User
        end
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
        related.show_tab? do |args|
          controller, model = args
          controller.current_user.has_view_for_model? Organization
        end
        related.add_title_block do |model|
          model.name if model
        end
        related.for_search do |model|
          model.related_organizations
        end
        related.display_template = '/organizations/related_organization'
      end
      insta.add_related do |related|
        related.display_name = 'Trans'
        related.show_tab? do |args|
          controller, model = args
          controller.current_user.has_view_for_model? RequestTransaction
        end
        related.add_title_block do |model|
          model.title if model
        end
        related.for_search do |model|
          model.related_request_transactions
        end
        related.display_template = '/request_transactions/related_request_transactions'
      end
      insta.add_related do |related|
        related.display_name = 'Reports'
        related.show_tab? do |args|
          controller, model = args
          controller.current_user.has_view_for_model? RequestReport
        end
        related.add_title_block do |model|
          model.title if model
        end
        related.for_search do |model|
          model.related_request_reports
        end
        related.display_template = '/request_reports/related_documents'
      end
      insta.add_related do |related|
        related.display_name = 'Projects'
        related.show_tab? do |args|
          controller, model = args
          controller.current_user.has_view_for_model? Project
        end
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
    def has_conversion_funnel
      true
    end
  end
end
