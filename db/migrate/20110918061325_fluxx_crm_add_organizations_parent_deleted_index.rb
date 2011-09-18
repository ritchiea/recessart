class FluxxCrmAddOrganizationsParentDeletedIndex < ActiveRecord::Migration
  def self.up
    add_index :organizations, [:parent_org_id, :deleted_at], :unique => false
  end

  def self.down
  end
end