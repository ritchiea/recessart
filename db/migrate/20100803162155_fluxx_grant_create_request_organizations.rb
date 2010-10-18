class FluxxGrantCreateRequestOrganizations < ActiveRecord::Migration
  def self.up
    create_table :request_organizations do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :organization_id, :null => true, :limit => 12
      t.string :description
    end
    add_index :request_organizations, [:request_id, :organization_id], :unique => true
    add_constraint 'request_organizations', 'request_organizations_request_id', 'request_id', 'requests', 'id'
    add_constraint 'request_organizations', 'request_organizations_organization_id', 'organization_id', 'organizations', 'id'
  end

  def self.down
    drop_table :request_organizations
  end
end