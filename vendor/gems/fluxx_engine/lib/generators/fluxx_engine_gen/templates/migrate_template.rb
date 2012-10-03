class <%= migration_class_name %> < ActiveRecord::Migration
  def self.up
    <%= migrate_up %>
  end

  def self.down
    <%= migrate_down %>
  end
end