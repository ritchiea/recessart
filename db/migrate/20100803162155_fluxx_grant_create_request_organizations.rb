class FluxxGrantCreateRequestOrganizations < ActiveRecord::Migration
  def self.up
    create_table :request_organizations do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :organization_id, :null => true, :limit => 12
      t.string :description
    end
    add_index :request_organizations, [:request_id, :organization_id], :unique => true
    execute "alter table request_organizations add constraint request_organizations_request_id foreign key (request_id) references requests(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table request_organizations add constraint request_organizations_organization_id foreign key (organization_id) references organizations(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :request_organizations
  end
end