class FluxxGrantAddProgramGeoZoneMeg < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO multi_element_groups (created_at, updated_at, name, description, target_class_name) values (now(), now(), 'geo_zone', 'Geo Zone', 'Program')"
    add_column :programs, :geo_zone_id, :integer
    add_constraint 'programs', 'program_geo_zone_id', 'geo_zone_id', 'multi_element_values', 'id'
  end

  def self.down
    remove_constraint 'programs', 'program_geo_zone_id'
    remove_column :programs, :geo_zone_id
    execute "DELETE FROM multi_element_groups where name = 'program_geo_zone' and target_class_name = 'Program'"
  end
end