module FluxxRequestUsersController
  def self.included(base)
    base.insta_index RequestUser do |insta|
      insta.template = 'request_user_list'
    end
    base.insta_show RequestUser do |insta|
      insta.template = 'request_user_show'
    end
    base.insta_new RequestUser do |insta|
      insta.template = 'request_user_form'
    end
    base.insta_edit RequestUser do |insta|
      insta.template = 'request_user_form'
    end
    base.insta_post RequestUser do |insta|
      insta.template = 'request_user_form'
    end
    base.insta_put RequestUser do |insta|
      insta.template = 'request_user_form'
    end
    base.insta_delete RequestUser do |insta|
      insta.template = 'request_user_form'
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