class FluxxCrmChangeAlertEmailRealtimeUpdateToModel < ActiveRecord::Migration
  def self.up
    change_table :alert_emails do |t|
      t.rename :realtime_update_id, :model_id
      t.string :model_type
    end
  end

  def self.down
    change_table :alert_emails do |t|
      t.rename :model_id, :realtime_update_id
      t.remove :model_type
    end
  end
end
