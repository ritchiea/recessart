class FluxxGrantMakeProjectSummaryATextField < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE requests change column project_summary project_summary text COLLATE utf8_unicode_ci"
  end

  def self.down
    execute "ALTER TABLE requests change column project_summary project_summary varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL"
  end
end