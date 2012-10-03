class FluxxGrantAddGrantFieldsToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :tax_class_id, :integer
  end

  def self.down
    remove_column :organizations, :tax_class_id
  end
end