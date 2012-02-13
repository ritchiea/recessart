class FluxxGrantCreateRequestReviewerAssignment < ActiveRecord::Migration
  def self.up
    create_table "request_reviewer_assignments", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :null => true, :limit => 12
      t.integer :user_id, :null => true, :limit => 12
    end

    add_constraint 'request_reviewer_assignments', 'request_reviewer_assignments_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'request_reviewer_assignments', 'request_reviewer_assignments_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'request_reviewer_assignments', 'request_reviewer_assignments_request_id', 'request_id', 'requests', 'id'
    add_constraint 'request_reviewer_assignments', 'request_reviewer_assignments_user_id', 'user_id', 'users', 'id'
  end

  def self.down
    drop_table "request_reviewer_assignments"
  end
end