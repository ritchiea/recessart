class FluxxCrmCreateAlertEmailTemplates < ActiveRecord::Migration
  def self.up
    create_table :alert_email_templates do |t|
      t.string :name
      t.text :subject
      t.text :body
    end
  end

  def self.down
    drop_table :alert_email_templates
  end
end
