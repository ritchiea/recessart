class FluxxCrmUserAddColumnForTestUserFlag < ActiveRecord::Migration
  def self.up
    add_column :users, :test_user_flag, :boolean
  end

  def self.down
    remove_column :users, :test_user_flag, :boolean
  end
end