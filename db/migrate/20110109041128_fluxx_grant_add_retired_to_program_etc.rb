class FluxxGrantAddRetiredToProgramEtc < ActiveRecord::Migration
  def self.up
    add_column :programs, :retired, :boolean
    add_column :sub_programs, :retired, :boolean
    add_column :initiatives, :retired, :boolean
    add_column :sub_initiatives, :retired, :boolean
  end

  def self.down
    add_column :programs, :retired
    add_column :sub_programs, :retired
    add_column :initiatives, :retired
    add_column :sub_initiatives, :retired
  end
end