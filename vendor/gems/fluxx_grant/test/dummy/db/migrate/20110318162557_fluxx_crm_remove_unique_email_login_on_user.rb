class FluxxCrmRemoveUniqueEmailLoginOnUser < ActiveRecord::Migration
  def self.up
    remove_index 'users', :name => 'index_users_on_login'
    remove_index 'users', :name => 'index_users_on_email'
    add_index :users, :login
    add_index :users, :email
  end

  def self.down
    remove_index 'users', :name => 'index_users_on_login'
    remove_index 'users', :name => 'index_users_on_email'
    add_index :users, :login, :unique => true
    add_index :users, :email, :unique => true
  end
end