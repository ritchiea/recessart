class FluxxCrmAddToggleToAlertTable < ActiveRecord::Migration
  def self.up
    change_table :alerts do |t|
      t.boolean :alert_enabled, :null => false, :default => true
    end
    execute "update alerts set alert_enabled = 1"
  end

  def self.down
    
  end
end