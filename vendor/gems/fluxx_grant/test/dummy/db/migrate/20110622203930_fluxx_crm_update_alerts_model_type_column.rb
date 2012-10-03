class FluxxCrmUpdateAlertsModelTypeColumn < ActiveRecord::Migration
  def self.up
    change_table :alerts do |t|
      t.rename :model_type, :model_controller_type
    end
  end

  def self.down
    change_table :alerts do |t|
      t.rename :model_controller_type, :model_type
    end
  end
end