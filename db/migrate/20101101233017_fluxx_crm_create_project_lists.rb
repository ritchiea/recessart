class FluxxCrmCreateProjectLists < ActiveRecord::Migration
  def self.up
    create_table :project_lists do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :title
      t.integer :project_id, :limit => 12
      t.integer :list_order   # order in which the list elements are displayed
      t.integer :list_type_id # links to a multi_element_value
    end

    add_constraint 'project_lists', 'project_lists_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'project_lists', 'project_lists_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'project_lists', 'project_lists_project_id', 'project_id', 'projects', 'id'
  end

  def self.down
    drop_table :project_lists
  end
end
