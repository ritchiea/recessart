class FluxxCrmCreateWorkflowEvents < ActiveRecord::Migration
  def self.up
    create_table :workflow_events do |t|
      t.timestamps
      t.integer :created_by_id
      t.integer :updated_by_id
      t.string :change_type
      t.string :workflowable_type
      t.integer :workflowable_id, :length => 12, :null => true
      t.string :ip_address
      t.string :old_state
      t.string :new_state
      t.text :comment
    end

    add_index :workflow_events, [:workflowable_id, :workflowable_type]
    add_constraint 'workflow_events', 'workflow_events_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'workflow_events', 'workflow_events_updated_by_id', 'updated_by_id', 'users', 'id'
  end

  def self.down
    drop_table :workflow_events
  end
end
