class FluxxCrmCreateGeoCities < ActiveRecord::Migration
  def self.up
    create_table :geo_cities do |t|
      t.timestamps
      t.string :name, :limit => 150, :null => false
      t.integer :geo_state_id, :limit => 12, :null => true
      t.integer :geo_country_id, :limit => 12, :null => true
      t.string :postalCode, :latitude, :longitude, :metro_code, :area_code, :limit => 150, :null => true
      t.integer :original_id, :limit => 12, :null => false # The original record ID supplied by maxmind
    end
    
    execute "alter table geo_cities add constraint geo_cities_state_id foreign key (geo_state_id) references geo_states(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table geo_cities add constraint geo_cities_country_id foreign key (geo_country_id) references geo_countries(id)" unless connection.adapter_name =~ /SQLite/i
    add_index :geo_cities, :name, :name => 'geo_cities_name_index'
  end

  def self.down
    drop_table :geo_cities
  end
end
