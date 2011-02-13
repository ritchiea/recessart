class FluxxCrmCreateRole < ActiveRecord::Migration
  def self.up
    create_table "roles", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name
      t.string :roleable_type
      t.datetime :deleted_at,                :null => true
    end
    
    add_constraint 'roles', 'roles_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'roles', 'roles_updated_by_id', 'updated_by_id', 'users', 'id'
    
    execute "insert into roles (created_at, updated_at, name, roleable_type) select #{current_time_function}, #{current_time_function}, name, roleable_type from role_users group by name, roleable_type"
   
    change_table :role_users do |t|
      t.integer :role_id
    end
    
    execute "update role_users set role_id = (select id from roles where roles.name = role_users.name and roles.roleable_type = role_users.roleable_type) where role_users.roleable_type is not null"
    execute "update role_users set role_id = (select id from roles where roles.name = role_users.name and roles.roleable_type is null) where role_users.roleable_type is null"

    change_table :role_users do |t|
      t.remove :name
      t.remove :roleable_type
    end
    
    add_constraint 'role_users', 'role_users_role_id', 'role_id', 'roles', 'id'
  end

  def self.down
    change_table :role_users do |t|
      t.string :name
      t.string :roleable_type
    end
    execute "update role_users set name = (select name from roles where roles.id = role_users.role_id)"
    execute "update role_users set roleable_type = (select roleable_type from roles where roles.id = role_users.role_id)"

    remove_constraint 'role_users', 'role_users_role_id'
    change_table :role_users do |t|
      t.drop :role_id
    end
    drop_table "roles"


  end
end