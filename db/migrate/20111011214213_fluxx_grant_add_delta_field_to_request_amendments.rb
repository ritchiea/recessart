class FluxxGrantAddDeltaFieldToRequestAmendments < ActiveRecord::Migration
  def self.up
    change_table :request_amendments do |t|
      t.boolean :delta, :null => false, :default => true
    end
  end

  def self.down
    change_table :request_amendments do |t|
      t.boolean :delta, :null => false, :default => true
    end
  end
end