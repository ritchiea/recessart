class FluxxGrantAddDocViewPrivsForBoardMembers < ActiveRecord::Migration
  def self.up
    execute "insert into user_profile_rules (created_at, updated_at, user_profile_id, permission_name, allowed, model_type) 
      values (now(), now(), (select id from user_profiles where name = 'Board'), 'view', 1, 'ModelDocument')"
    execute "insert into user_profile_rules (created_at, updated_at, user_profile_id, permission_name, allowed, model_type) 
      values (now(), now(), (select id from user_profiles where name = 'Board'), 'listview', 1, 'ModelDocument')"
  end

  def self.down
    execute "delete from user_profile_rules 
      where user_profile_id = (select id from user_profiles where name = 'Board'), permission_name='view', allowed=1, model_type='ModelDocument'"
    execute "delete from user_profile_rules 
      where user_profile_id = (select id from user_profiles where name = 'Board'), permission_name='listview', allowed=1, model_type='ModelDocument'"
  end
end