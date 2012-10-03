class FluxxCrmCreateProjectOrganizations < ActiveRecord::Migration
  def self.up
    create_table :project_organizations do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :project_id, :limit => 12
      t.integer :organization_id, :limit => 12
    end

    add_constraint 'project_organizations', 'project_organizations_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'project_organizations', 'project_organizations_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'project_organizations', 'project_organizations_project_id', 'project_id', 'projects', 'id'
    add_constraint 'project_organizations', 'project_organizations_organization_id', 'organization_id', 'organizations', 'id'
  end

  def self.down
    drop_table :project_organizations
  end
end
