class FluxxCrmCreateGeoStates < ActiveRecord::Migration
  def self.up
    create_table :geo_states do |t|
      t.timestamps
      t.string :name, :limit => 90, :null => false
      t.string :fips_10_4, :limit => 90, :null => false
      t.string :abbreviation, :limit => 25, :null => true
      t.integer :geo_country_id, :limit => 12, :null => false
    end

    execute "alter table geo_states add constraint geo_states_country_id foreign key (geo_country_id) references geo_countries(id)" unless connection.adapter_name =~ /SQLite/i
    add_index :geo_states, :name, :name => 'geo_states_name_index'
    add_index :geo_states, :abbreviation, :name => 'geo_states_abbrv_index'
  end

  def self.down
    drop_table :geo_states
  end
end