class FluxxCrmDropAlertEmailTemplates < ActiveRecord::Migration
  def self.up
    drop_table :alert_email_templates
  end

  def self.down
    create_table :alert_email_templates do |t|
      t.string :name
      t.text :subject
      t.text :body
    end
  end
end
