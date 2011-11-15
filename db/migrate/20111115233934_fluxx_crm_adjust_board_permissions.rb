class FluxxCrmAdjustBoardPermissions < ActiveRecord::Migration
  def self.up
    execute "delete from user_profile_rules where user_profile_id = (select id from user_profiles where name = 'Board') and permission_name = 'listview'"
    execute "insert into user_profile_rules (user_profile_id, permission_name, allowed, model_type) 
      values ((select id from user_profiles where name = 'Board'), 'listview_own', 1, 'ModelDocument')"
  end

  def self.down
    
  end
end