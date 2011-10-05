class FluxxCrmAddDocumentTypeToModelDocumentTypes < ActiveRecord::Migration
  def self.up
    add_column :model_document_templates, :document_content_type, :string
  end

  def self.down
    remove_column :model_document_templates, :document_content_type, :string
  end
end