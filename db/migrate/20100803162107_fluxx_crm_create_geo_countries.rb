class FluxxCrmCreateGeoCountries < ActiveRecord::Migration
  def self.up
    create_table :geo_countries do |t|
      t.timestamps
      t.string :name, :limit => 90, :null => false
      t.string :fips104, :iso2, :iso3, :ison, :internet, :capital, :map_reference, :nationality_singular, :nationality_plural, :currency, :currency_code, :population, :title, :limit => 90, :null => true
      t.text :comment, :null => true
      t.integer :original_id, :limit => 12, :null => false # The original record ID supplied by maxmind
    end
    add_index :geo_countries, :name, :name => 'country_name_index'
    add_index :geo_countries, :iso2, :name => 'country_iso2_index'
  end

  def self.down
    drop_table :geo_countries
  end
end

