class FluxxCrmAddCcToEmailForAlerts < ActiveRecord::Migration
  def self.up
    change_table :alerts do |t|
      t.text :cc_emails
      t.text :bcc_emails
    end
  end

  def self.down
    
  end
end