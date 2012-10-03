class AddAuthlogicToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :crypted_password, :string, :limit => 128, :default => "", :null => false
    add_column :users, :password_salt, :string, :default => "", :null => false
    add_column :users, :persistence_token, :string
    add_column :users, :single_access_token, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    
    add_column :users, :login_count, :integer, :default => 0
    add_column :users, :failed_login_count, :integer, :default => 0
    add_column :users, :current_login_at, :datetime
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_ip, :string
    
    add_index :users, :persistence_token
    add_index :users, :single_access_token
  end

  def self.down
    remove_column :users, :crypted_password
    remove_column :users, :password_salt
    remove_column :users, :persistence_token
    remove_column :users, :single_access_token
    remove_column :users, :confirmation_sent_at
    
    remove_column :users, :login_count
    remove_column :users, :failed_login_count
    remove_column :users, :last_request_at
    remove_column :users, :current_login_at
    remove_column :users, :last_login_at
    remove_column :users, :current_login_ip
    remove_column :users, :last_login_ip
    
    remove_index :users, :persistence_token
    remove_index :users, :single_access_token
  end
end
