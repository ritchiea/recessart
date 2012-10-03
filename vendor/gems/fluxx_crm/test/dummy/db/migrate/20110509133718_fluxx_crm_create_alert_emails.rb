class FluxxCrmCreateAlertEmails < ActiveRecord::Migration
  def self.up
    create_table :alert_emails do |t|
      t.string :mailer_method
      t.integer :attempts, :default => 0
      t.datetime :last_attempt_at
      t.boolean :delivered, :default => false
      t.references :alert
      t.references :realtime_update
      t.timestamps
    end
  end

  def self.down
    drop_table :alert_emails
  end
end
