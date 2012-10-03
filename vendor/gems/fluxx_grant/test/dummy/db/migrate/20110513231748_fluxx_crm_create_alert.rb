class FluxxCrmCreateAlert < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.timestamps
      t.integer :last_realtime_update_id
      t.references :alert_email_template
      t.string :model_type
      t.text :filter
    end
  end

  def self.down
    drop_table :alerts
  end
end
