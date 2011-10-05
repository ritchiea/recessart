class FluxxCrmAddStateTransitionConditionToAlerts < ActiveRecord::Migration
  def self.up
    change_table :alerts do |t|
      t.boolean :state_driven, :default => false, :null => false
      t.string :state_driven_transition
    end
    execute "update alerts set state_driven = 0"
  end

  def self.down
    change_table :alerts do |t|
      t.remove :state_driven
    end
  end
end