class FluxxCrmFixUserProfileRules < ActiveRecord::Migration
  def self.up
    execute "update user_profile_rules set permission_name = 'view', model_type = 'User' where permission_name = 'view_user'"
    execute "update user_profile_rules set permission_name = 'view', model_type = 'Organization' where permission_name = 'view_organization'"
    execute "update user_profile_rules set permission_name = 'view', model_type = 'Request' where permission_name = 'view_grant'"
    execute "update user_profile_rules set permission_name = 'view', model_type = 'Request' where permission_name = 'view_request'"
    execute "update user_profile_rules set permission_name = 'view', model_type = 'RequestReport' where permission_name = 'view_report'"
    execute "update user_profile_rules set permission_name = 'view', model_type = 'RequestTransaction' where permission_name = 'view_transaction'"
    execute "update user_profile_rules set permission_name = 'create', model_type = 'Request' where permission_name = 'create_request'"
    execute "update user_profile_rules set permission_name = 'create_own', model_type = 'Request' where permission_name = 'create_own_request'"
    execute "update user_profile_rules set permission_name = 'view_own', model_type = 'Request' where permission_name = 'view_own_request'"
  end

  def self.down
    
  end
end