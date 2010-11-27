class FluxxCrmCreateModelDocumentTemplates < ActiveRecord::Migration
  def self.up
    create_table :model_document_templates do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :model_type
      t.string :document_type
      t.string :filename
      t.string :description
      t.string :category
      t.text :document
      t.datetime :deleted_at, :null => true
      t.boolean :delta, :null => false, :default => true
    end

    add_index :model_document_templates, :document_type
    add_index :model_document_templates, :category
    add_index :model_document_templates, :model_type
        
    add_constraint 'model_document_templates', 'modeldoctemplate_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'model_document_templates', 'modeldoctemplate_updated_by_id', 'updated_by_id', 'users', 'id'
    
    add_column :model_documents, :document_type, :string, :default => 'file'
    add_column :model_documents, :document_text, :text
    add_column :model_documents, :model_document_template_id, :integer
    add_constraint 'model_documents', 'model_documents_template_id', 'model_document_template_id', 'model_document_templates', 'id'
  end

  def self.down
    remove_constraint 'model_documents', 'model_documents_template_id'
    remove_column :model_documents, :model_document_template_id
    drop_table :model_document_templates
  end
end