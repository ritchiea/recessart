class FluxxGrantCreateProjectRequests < ActiveRecord::Migration
  def self.up
    create_table :project_requests do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :project_id, :limit => 12
      t.integer :request_id, :limit => 12
      t.boolean :granted
    end

    add_constraint 'project_requests', 'project_requests_created_by_id', 'created_by_id', 'requests', 'id'
    add_constraint 'project_requests', 'project_requests_updated_by_id', 'updated_by_id', 'requests', 'id'
    add_constraint 'project_requests', 'project_requests_project_id', 'project_id', 'projects', 'id'
    add_constraint 'project_requests', 'project_requests_request_id', 'request_id', 'requests', 'id'
  end

  def self.down
    drop_table :project_requests
  end
end
