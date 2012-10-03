class FluxxCrmAddRelatedWorkflowableToNotes < ActiveRecord::Migration
  def self.up
    change_table :workflow_events do |t|
      t.string :related_workflowable_type
      t.integer :related_workflowable_id
    end
  end

  def self.down
    change_table :workflow_events do |t|
      t.remove :related_workflowable_type
      t.remove :related_workflowable_id
    end
  end
end