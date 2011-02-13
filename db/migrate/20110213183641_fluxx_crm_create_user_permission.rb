class FluxxCrmCreateUserPermission < ActiveRecord::Migration
  def self.up
    create_table "user_permissions", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      
      t.string :model_type, :null => true
      t.integer :user_id, :null => true, :limit => 12
      t.string :name
    end

    add_constraint 'user_permissions', 'user_permissions_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'user_permissions', 'user_permissions_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'user_permissions', 'user_permissions_user_id', 'user_id', 'users', 'id'
    
    change_table :user_profile_rules do |t|
      t.rename :role_name, :permission_name
      t.string :model_type
    end
    
    execute "insert into user_permissions (created_at, updated_at, model_type, user_id, name) 
        select now(), now(), null, user_id, 'admin' from role_users where role_id = (select id from roles where name = 'admin')"
  end

  def self.down
    drop_table "user_permissions"
  end
end