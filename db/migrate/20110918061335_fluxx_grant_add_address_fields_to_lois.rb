class FluxxGrantAddAddressFieldsToLois < ActiveRecord::Migration
  def self.up
    add_column :lois, :street_address2, :string, :limit => 255, :null => true
    add_column :lois, :city, :string, :limit => 100, :null => true
    add_column :lois, :geo_state_id, :integer, :null => true
    add_column :lois, :geo_country_id,:integer, :null => true
    add_column :lois, :postal_code, :string, :limit => 100, :null => true
  end

  def self.down
    remove_column :lois, :street_address2
    remove_column :lois, :city, :string
    remove_column :lois, :geo_state_id
    remove_column :lois, :geo_country_id
    remove_column :lois, :postal_code
  end
end