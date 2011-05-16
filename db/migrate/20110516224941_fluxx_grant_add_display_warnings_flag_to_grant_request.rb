class FluxxGrantAddDisplayWarningsFlagToGrantRequest < ActiveRecord::Migration
  def self.up
    change_table :requests do |t|
      t.boolean :display_warnings, :default => true
    end
  end

  def self.down
    change_table :requests do |t|
      t.remove :display_warnings
    end
  end
end
