class FluxxGrantAddDeltaColumnToLoi < ActiveRecord::Migration
  def self.up
    add_column :lois, :delta, :boolean, :default => true
  end

  def self.down
    remove_column :lois, :delta
  end
end