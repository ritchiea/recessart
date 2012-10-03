module FluxxUserProfileRule
  def self.included(base)
    base.belongs_to :user_profile
    
    base.insta_search do |insta|
      insta.really_delete = true
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