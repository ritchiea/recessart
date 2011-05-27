class FluxxGrantCorrectProjectRequestConstraint < ActiveRecord::Migration
  def self.up
    remove_constraint 'project_requests', 'project_requests_created_by_id'
    remove_constraint 'project_requests', 'project_requests_updated_by_id'
    add_constraint 'project_requests', 'project_requests_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'project_requests', 'project_requests_updated_by_id', 'updated_by_id', 'users', 'id'
  end

  def self.down
    
  end
end