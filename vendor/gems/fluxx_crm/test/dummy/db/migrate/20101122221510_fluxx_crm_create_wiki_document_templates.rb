class FluxxCrmCreateWikiDocumentTemplates < ActiveRecord::Migration
  def self.up
    create_table :wiki_document_templates do |t|
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

    add_index :wiki_document_templates, :document_type
    add_index :wiki_document_templates, :category
    add_index :wiki_document_templates, :model_type
        
    add_constraint 'wiki_document_templates', 'wikdoctemplate_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'wiki_document_templates', 'wikdoctemplate_updated_by_id', 'updated_by_id', 'users', 'id'
    
    add_column :wiki_documents, :wiki_document_template_id, :integer
    add_constraint 'wiki_documents', 'wiki_documents_template_id', 'wiki_document_template_id', 'wiki_document_templates', 'id'
  end

  def self.down
    remove_constraint 'wiki_documents', 'wiki_documents_template_id'
    remove_column :wiki_documents, :wiki_document_template_id
    drop_table :wiki_document_templates
  end
end