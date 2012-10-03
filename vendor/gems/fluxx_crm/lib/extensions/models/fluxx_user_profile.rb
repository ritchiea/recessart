module FluxxUserProfile
  def self.included(base)
    
    base.has_many :user_profile_rules
    base.insta_search do |insta|
      insta.really_delete = true
    end
    base.cattr_accessor :cached_all_user_profile_hash
    base.cattr_accessor :cached_all_user_profile_rules

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    def clear_cache
      UserProfile.cached_all_user_profile_hash = nil
      UserProfile.cached_all_user_profile_rules = nil
    end
    
    # Works fine as long as there aren't many user profile rules
    def all_user_profile_rules
      unless UserProfile.cached_all_user_profile_rules
        UserProfile.cached_all_user_profile_rules = UserProfileRule.all 
      end
      UserProfile.cached_all_user_profile_rules
    end
    

    def all_user_profile_map
      unless UserProfile.cached_all_user_profile_hash
        UserProfile.cached_all_user_profile_hash = UserProfile.all.inject(HashWithIndifferentAccess.new) {|acc, up| acc[up.id] = up; acc} 
      end
      UserProfile.cached_all_user_profile_hash
    end
    
    def all_user_profile_map_by_name
      UserProfile.all_user_profile_map.values.inject({}) {|acc, up| acc[up.name] = up; acc}
    end
  end

  module ModelInstanceMethods
    
    def has_rule? permission_name, model_type
      UserProfile.all_user_profile_rules.select{|rule| rule.user_profile_id == self.id && rule.permission_name == permission_name && rule.model_type == model_type}.first
    end
  end
end