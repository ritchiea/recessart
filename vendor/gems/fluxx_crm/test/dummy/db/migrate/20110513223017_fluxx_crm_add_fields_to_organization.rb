class FluxxCrmAddFieldsToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :tax_id, :string
  end

  def self.down
    remove_column :organizations, :tax_id
  end
end