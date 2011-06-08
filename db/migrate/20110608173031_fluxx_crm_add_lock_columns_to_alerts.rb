class FluxxCrmAddLockColumnsToAlerts < ActiveRecord::Migration
  def self.up
    change_table "alerts" do |t|
      t.datetime :locked_until, :null => true
      t.integer :locked_by_id,  :null => true
    end
  end

  def self.down
    change_table "alerts" do |t|
      t.remove :locked_by_id
      t.remove :locked_until
    end
  end
end
