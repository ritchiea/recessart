class FluxxGrantAddMigrateIdToTables < ActiveRecord::Migration
  def self.up
    add_column :lois, :migrate_id, :integer
    add_column :organizations, :migrate_id, :integer
    add_column :programs, :migrate_id, :integer
    add_column :sub_programs, :migrate_id, :integer
    add_column :initiatives, :migrate_id, :integer
    add_column :sub_initiatives, :migrate_id, :integer
    add_column :requests, :migrate_id, :integer
    add_column :request_transactions, :migrate_id, :integer
    add_column :users, :migrate_id, :integer
  end

  def self.down
    remove_column :lois, :migrate_id
    remove_column :organizations, :migrate_id
    remove_column :programs, :migrate_id
    remove_column :sub_programs, :migrate_id
    remove_column :initiatives, :migrate_id
    remove_column :sub_initiatives, :migrate_id
    remove_column :requests, :migrate_id
    remove_column :request_transactions, :migrate_id
    remove_column :users, :migrate_id
    
  end
end