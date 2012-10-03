class FluxxCrmAddGenerateStateToModelDocumentTemplates < ActiveRecord::Migration
  def self.up
    add_column :model_document_templates, :generate_state, :string
  end

  def self.down
    remove_column :model_document_templates, :generate_state
    
  end
end