class FluxxCrmCreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :title
      t.text :description
      t.string :state
      t.integer :project_type_id # links to a multi_element_value
      t.integer :lead_user_id, :limit => 12
      t.datetime :deleted_at,                :null => true
      t.datetime :locked_until,              :null => true
      t.integer :locked_by_id,               :null => true
      t.boolean :delta, :null => false, :default => true
    end

    add_constraint 'projects', 'projects_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'projects', 'projects_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'projects', 'projects_lead_user_id', 'lead_user_id', 'users', 'id'
  end

  def self.down
    drop_table :projects
  end
end
