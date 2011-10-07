class FluxxCrmCreateAlertTransitionState < ActiveRecord::Migration
  def self.up
    create_table "alert_transition_states", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :alert_id
      t.string :state
    end

    add_constraint 'alert_transition_states', 'alert_transition_states_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'alert_transition_states', 'alert_transition_states_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'alert_transition_states', 'alert_transition_states_alert_id', 'alert_id', 'alerts', 'id'
    
    execute "insert into alert_transition_states (created_at, updated_at, alert_id, state) 
             select now(), now(), id, state_driven_transition from alerts where state_driven_transition is not null and state_driven is not null"
             
    change_table :alerts do |t|
     t.remove :state_driven_transition
    end
  end

  def self.down
    change_table :alerts do |t|
     t.string :state_driven_transition
    end
    drop_table "alert_transition_states"
  end
end