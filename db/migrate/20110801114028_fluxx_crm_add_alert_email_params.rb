class FluxxCrmAddAlertEmailParams < ActiveRecord::Migration
  def self.up
    change_table :alert_emails do |t|
      t.text :email_params
    end
  end

  def self.down
    change_table :alert_emails do |t|
      t.remove :email_params
    end
  end
end