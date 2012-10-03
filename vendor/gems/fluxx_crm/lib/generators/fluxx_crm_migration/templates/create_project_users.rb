class FluxxCrmCreateProjectUsers < ActiveRecord::Migration
  def self.up
    create_table :project_users do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :project_id, :limit => 12
      t.integer :user_id, :limit => 12
    end

    add_constraint 'project_users', 'project_users_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'project_users', 'project_users_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'project_users', 'project_users_project_id', 'project_id', 'projects', 'id'
    add_constraint 'project_users', 'project_users_user_id', 'user_id', 'users', 'id'
  end

  def self.down
    drop_table :project_users
  end
end
