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
    execute "alter table workflow_events add constraint workflow_events_created_by_id foreign key (created_by_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table workflow_events add constraint workflow_events_updated_by_id foreign key (updated_by_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :workflow_events
  end
end
