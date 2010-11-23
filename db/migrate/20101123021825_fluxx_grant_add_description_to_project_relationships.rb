class FluxxGrantAddDescriptionToProjectRelationships < ActiveRecord::Migration
  def self.up
    add_column :project_requests, :description, :string
  end

  def self.down
    remove_column :project_requests, :description
  end
end
