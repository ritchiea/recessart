class FluxxCrmChangeAlertTypeToModelType < ActiveRecord::Migration
  def self.up
    change_table :alerts do |t|
      t.rename :type, :model_type
    end rescue nil
  end

  def self.down
    change_table :alerts do |t|
      t.rename :model_type, :type
    end
  end
end
