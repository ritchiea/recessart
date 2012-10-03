class FluxxCrmAddDescriptionToProjectRelationships < ActiveRecord::Migration
  def self.up
    add_column :project_users, :description, :string
    add_column :project_organizations, :description, :string
  end

  def self.down
    remove_column :project_users, :description
    remove_column :project_organizations, :description
  end
end
