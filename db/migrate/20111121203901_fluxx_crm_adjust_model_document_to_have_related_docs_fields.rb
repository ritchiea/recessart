class FluxxCrmAdjustModelDocumentToHaveRelatedDocsFields < ActiveRecord::Migration
  def self.up
    change_table :model_document_templates do |t|
      t.string :disposition
      t.integer :related_model_document_id
    end
    
    add_constraint 'model_document_templates', 'mdt_related_model_document_id', 'related_model_document_id', 'model_document_templates', 'id'
  end

  def self.down
    
  end
end