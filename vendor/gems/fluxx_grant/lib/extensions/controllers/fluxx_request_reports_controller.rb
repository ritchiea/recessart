module FluxxRequestReportsController
  ICON_STYLE = 'style-reports'
  def self.included(base)
    base.insta_index RequestReport do |insta|
      insta.template = 'request_report_list'
      insta.filter_title = "Grantee Reports Filter"
      insta.filter_template = 'request_reports/request_report_filter'
      insta.order_clause = 'due_at desc'
      insta.icon_style = ICON_STYLE
      insta.search_conditions = (lambda do |params, controller_dsl, controller|
        if controller.current_user.is_board_member?
          {:state => "approved"}
        end
      end)
    end
    base.insta_show RequestReport do |insta|
      insta.template = 'request_report_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.post do |triple|
        controller_dsl, model, outcome = triple
        request_report = model
        unless request_report && (request_report.is_final_eval_report_type? || request_report.is_interim_eval_report_type?)
          @edit_enabled = false
        end
      end
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          if params[:view_states]
            local_model = instance_variable_get '@model'
            send :fluxx_show_card, controller_dsl, {:template => 'request_reports/view_states', :footer_template => 'insta/simple_footer'}
          else
           default_block.call
          end
        end
      end
    end
    base.insta_new RequestReport do |insta|
      insta.template = 'request_report_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit RequestReport do |insta|
      insta.template = 'request_report_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post RequestReport do |insta|
      insta.template = 'request_report_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put RequestReport do |insta|
      insta.template = 'request_report_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete RequestReport do |insta|
      insta.template = 'request_report_form'
      insta.icon_style = ICON_STYLE
    end
    
    base.insta_related RequestReport do |insta|
      insta.add_related do |related|
        related.display_name = 'People'
        related.show_tab? do |args|
          controller, model = args
          controller.current_user.has_view_for_model? User
        end
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
        related.show_tab? do |args|
          controller, model = args
          controller.current_user.has_view_for_model? Organization
        end
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
        related.show_tab? do |args|
          controller, model = args
          controller.current_user.has_view_for_model? Request
        end
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
        related.display_name = 'Reports'
        related.show_tab? do |args|
          controller, model = args
          controller.current_user.has_view_for_model? RequestReport
        end
        related.for_search do |model|
          model.related_reports
        end
        related.add_title_block do |model|
          model.title if model
        end
        related.display_template = '/request_reports/related_documents'
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