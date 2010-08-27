class FluxxCrmCreateRoleUsers < ActiveRecord::Migration
  def self.up
    create_table :role_users do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name, :null => false
      t.integer :user_id, :null => true, :limit => 12
      t.string :roleable_type, :null => true
      t.integer :roleable_id, :null => true, :limit => 12
    end
    add_index :role_users, [:name, :roleable_type, :roleable_id]
    add_index :role_users, :user_id
    execute "alter table role_users add constraint role_users_created_by_id foreign key (created_by_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table role_users add constraint role_users_updated_by_id foreign key (updated_by_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table role_users add constraint role_users_user_id foreign key (user_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :role_users
  end
end
