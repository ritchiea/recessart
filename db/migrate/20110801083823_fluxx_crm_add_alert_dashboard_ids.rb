class FluxxCrmAddAlertDashboardIds < ActiveRecord::Migration
  def self.up
    change_table :alerts do |t|
      t.integer :dashboard_id
      t.integer :dashboard_card_id
    end
    
    add_constraint 'alerts', 'alerts_dashboard_id', 'dashboard_id', 'client_stores', 'id'
  end

  def self.down
    add_constraint 'alerts', 'alerts_dashboard_id'
    change_table :alerts do |t|
      t.remove :dashboard_id
      t.remove :dashboard_card_id
    end
  end
end