class FluxxCrmAddStateAndCountryFieldsToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :state_str, :string
    add_column :organizations, :state_code, :string
    add_column :organizations, :country_str, :string
    add_column :organizations, :country_code, :string
  end

  def self.down
    remove_column :organizations, :country_code
    remove_column :organizations, :country_str
    remove_column :organizations, :state_code
    remove_column :organizations, :state_str
  end
end