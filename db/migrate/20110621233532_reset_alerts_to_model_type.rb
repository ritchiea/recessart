class ResetAlertsToModelType < ActiveRecord::Migration
  def self.up
    change_table :alerts do |t|
      t.rename :type, :model_type
    end
  end

  def self.down
  end
end
