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
    execute "alter table request_users add constraint request_users_request_id foreign key (request_id) references requests(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table request_users add constraint request_users_user_id foreign key (user_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :request_users
  end
end