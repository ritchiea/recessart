module FluxxAdminItemsController
  ICON_STYLE = 'style-admins'
  def self.included(base)
    base.insta_index AdminItem do |insta|
      insta.template = 'admin_item_list'
      insta.icon_style = ICON_STYLE
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          render "index", :layout => false
        end
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