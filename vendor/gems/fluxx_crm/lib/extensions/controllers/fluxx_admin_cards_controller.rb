module FluxxAdminCardsController
  ICON_STYLE = 'style-admin-cards'
  def self.included(base)
    base.insta_show User do |insta|
      insta.template = 'admin_card_show'
      insta.icon_style = ICON_STYLE
      insta.footer_template =  'insta/simple_footer'

      insta.pre do |conf|
        self.pre_model = 'n/a'
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