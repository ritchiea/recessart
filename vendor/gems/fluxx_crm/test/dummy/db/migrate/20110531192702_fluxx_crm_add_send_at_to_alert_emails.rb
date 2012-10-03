class FluxxCrmAddSendAtToAlertEmails < ActiveRecord::Migration
  def self.up
    change_table :alert_emails do |t|
      t.datetime :send_at
    end
  end

  def self.down
    change_table :alert_emails do |t|
      t.remove :send_at
    end
  end
end
