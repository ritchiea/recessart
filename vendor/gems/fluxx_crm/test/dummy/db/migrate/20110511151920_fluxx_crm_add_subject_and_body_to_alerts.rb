class FluxxCrmAddSubjectAndBodyToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :subject, :string
    add_column :alerts, :body, :text
    remove_column :alerts, :alert_email_template_id
  end

  def self.down
    add_column :alerts, :alert_email_template_id, :integer
    remove_column :alerts, :body
    remove_column :alerts, :subject
  end
end
