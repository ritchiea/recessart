class FluxxCrmCreateGeoStates < ActiveRecord::Migration
  def self.up
    create_table :geo_states do |t|
      t.timestamps
      t.string :name, :limit => 90, :null => false
      t.string :fips_10_4, :limit => 90, :null => false
      t.string :abbreviation, :limit => 25, :null => true
      t.integer :geo_country_id, :limit => 12, :null => false
    end

    add_constraint 'geo_states', 'geo_states_country_id', 'geo_country_id', 'geo_countries', 'id'
    add_index :geo_states, :name, :name => 'geo_states_name_index'
    add_index :geo_states, :abbreviation, :name => 'geo_states_abbrv_index'
  end

  def self.down
    drop_table :geo_states
  end
end