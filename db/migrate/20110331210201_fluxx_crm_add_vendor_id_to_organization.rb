class FluxxCrmAddVendorIdToOrganization < ActiveRecord::Migration
  def self.up
    change_table :organizations do |t|
      t.string :vendor_number
    end
  end

  def self.down
    change_table :organizations do |t|
      t.remove :vendor_number
    end
  end
end