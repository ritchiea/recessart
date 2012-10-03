module FluxxAlertsController
  extend FluxxModuleHelper

  ICON_STYLE = 'style-alerts'

  when_included do
    insta_index Alert do |insta|
      insta.template = 'alert_list'
      insta.filter_title = "Alerts Filter"
      insta.filter_template = 'alerts/alert_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    insta_show Alert do |insta|
      insta.template = 'alert_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    insta_new Alert do |insta|
      insta.template = 'alert_form'
      insta.icon_style = ICON_STYLE
    end
    insta_edit Alert do |insta|
      insta.template = 'alert_form'
      insta.icon_style = ICON_STYLE
    end
    insta_post Alert do |insta|
      insta.template = 'alert_form'
      insta.icon_style = ICON_STYLE
      #insta.new_block = lambda do |params|
      #  (params[:alert][:model_type] ? params[:alert][:model_type].constantize : Alert).new.tap do |alert|
      #    alert.update_attributes(params[:alert])
      #  end
      #end
    end
    insta_put Alert do |insta|
      insta.template = 'alert_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    insta_delete Alert do |insta|
      insta.template = 'alert_form'
      insta.icon_style = ICON_STYLE
    end
    insta_related Alert do |insta|
      insta.add_related do |related|
      end
    end
  end
end

