class FluxxGrantRenameLoiOrganizationName < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE lois change column organization organization_name varchar(255) DEFAULT NULL"
  end

  def self.down
    
  end
end