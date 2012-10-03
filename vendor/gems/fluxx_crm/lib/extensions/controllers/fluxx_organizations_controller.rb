module FluxxOrganizationsController
  ICON_STYLE = 'style-organizations'
  def self.included(base)
    base.insta_index Organization do |insta|
      insta.template = 'organization_list'
      insta.order_clause = 'name asc'
      insta.search_conditions = {:parent_org_id => nil}
      insta.icon_style = ICON_STYLE
    end
    base.insta_show Organization do |insta|
      insta.template = 'organization_show'
      insta.icon_style = ICON_STYLE
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          if params[:satellites] == '1'
            send :fluxx_show_card, controller_dsl, {:template => 'organizations/organization_satellites', :footer_template => 'insta/simple_footer', :layout => false}
          else
            default_block.call
          end
        end
      end
    end
    base.insta_new Organization do |insta|
      insta.template = 'organization_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit Organization do |insta|
      insta.template = 'organization_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post Organization do |insta|
      insta.template = 'organization_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put Organization do |insta|
      insta.template = 'organization_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_delete Organization do |insta|
      insta.template = 'organization_form'
      insta.icon_style = ICON_STYLE
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