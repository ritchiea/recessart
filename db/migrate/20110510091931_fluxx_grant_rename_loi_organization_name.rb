class FluxxGrantRenameLoiOrganizationName < ActiveRecord::Migration
  def self.up
    rename_column :lois, :organization, :organization_name
  end

  def self.down
    
  end
end