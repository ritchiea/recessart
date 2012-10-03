class FluxxGrantCreateRequestUsers < ActiveRecord::Migration
  def self.up
    create_table :request_users do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :null => true, :limit => 12
      t.integer :user_id, :null => true, :limit => 12
      t.string :description
    end
    add_index :request_users, :request_id
    add_index :request_users, :user_id
    add_constraint 'request_users', 'request_users_request_id', 'request_id', 'requests', 'id'
    add_constraint 'request_users', 'request_users_user_id', 'user_id', 'users', 'id'
  end

  def self.down
    drop_table :request_users
  end
end