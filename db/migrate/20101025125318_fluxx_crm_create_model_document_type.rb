class FluxxCrmCreateModelDocumentType < ActiveRecord::Migration
  def self.up
    create_table :model_document_types do |t|
      t.timestamps
      t.integer :created_by_id
      t.integer :updated_by_id
      t.string :name, :null => false # name of the model document
      t.string :model_type, :null => false # name of the model type (Request, Organization)
      t.boolean :required, :null => false, :default => true 
    end

    add_index :model_document_types, :model_type
    add_constraint 'model_document_types', 'model_document_types_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'model_document_types', 'model_document_types_updated_by_id', 'updated_by_id', 'users', 'id'
    
    add_column :model_documents, :model_document_type_id, :integer, :null => true
    add_constraint 'model_documents', 'model_documents_model_document_type_id', 'model_document_type_id', 'model_document_types', 'id'
  end

  def self.down
    remove_constraint 'model_documents', 'model_documents_model_document_type_id', 'model_document_types'
    remove_column :model_documents, :model_document_type_id
    drop_table :model_document_types
  end
end
