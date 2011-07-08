class AddRetiredOrganizationDocumentTypeAlias < ActiveRecord::Migration
  def self.up
    ModelDocumentType.create :name => 'Retired', :model_type => Organization.name
  end

  def self.down
  end
end
