class FluxxCrmCreateGeoRegions < ActiveRecord::Migration
  def self.up
    create_table :geo_regions do |t|
      t.timestamps
      t.string :name, :null => false
    end
    
    add_column :geo_states, :geo_region_id, :integer
    add_constraint 'geo_states', 'geo_states_geo_region_id', 'geo_region_id', 'geo_regions', 'id'
  end

  def self.down
    remove_constraint 'geo_states', 'geo_states_geo_region_id'
    remove_column :geo_states, :geo_region_id
    
    drop_table :geo_regions
  end
end
