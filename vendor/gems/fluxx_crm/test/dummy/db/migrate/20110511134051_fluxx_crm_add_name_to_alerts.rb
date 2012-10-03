class FluxxCrmAddNameToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :name, :string
  end

  def self.down
    remove_column :alerts, :name
  end
end
