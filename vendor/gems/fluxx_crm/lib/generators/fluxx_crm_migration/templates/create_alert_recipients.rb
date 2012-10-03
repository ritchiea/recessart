class FluxxCrmCreateAlertRecipients < ActiveRecord::Migration
  def self.up
    create_table :alert_recipients do |t|
      t.references :user
      t.references :alert
      t.text :rtu_model_user_method
      t.timestamps
    end
  end

  def self.down
    drop_table :alert_recipients
  end
end
