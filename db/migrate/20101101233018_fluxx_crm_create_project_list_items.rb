class FluxxCrmCreateProjectListItems < ActiveRecord::Migration
  def self.up
    create_table :project_list_items do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name
      t.text :list_item_text
      t.integer :project_list_id, :limit => 12
      t.datetime :due_at
      t.integer :item_order   # order in which the item elements are displayed
      t.integer :assigned_user_id, :limit => 12
      t.boolean :item_completed, :default => '0'
      t.datetime :deleted_at,                :null => true
      t.datetime :locked_until,              :null => true
      t.integer :locked_by_id,               :null => true
    end

    add_constraint 'project_list_items', 'project_list_items_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'project_list_items', 'project_list_items_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'project_list_items', 'project_list_items_assigned_user_id', 'assigned_user_id', 'users', 'id'
    
    add_constraint 'project_list_items', 'project_list_items_project_list_id', 'project_list_id', 'project_lists', 'id'
  end

  def self.down
    drop_table :project_list_items
  end
end
