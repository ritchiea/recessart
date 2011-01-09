class FluxxGrantAddRetiredToProgramEtc < ActiveRecord::Migration
  def self.up
    add_column :programs, :retired, :boolean, :null => false, :default => false
    add_column :sub_programs, :retired, :boolean, :null => false, :default => false
    add_column :initiatives, :retired, :boolean, :null => false, :default => false
    add_column :sub_initiatives, :retired, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :programs, :retired
    remove_column :sub_programs, :retired
    remove_column :initiatives, :retired
    remove_column :sub_initiatives, :retired
  end
end