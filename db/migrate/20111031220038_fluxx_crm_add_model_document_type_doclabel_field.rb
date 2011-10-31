class FluxxCrmAddModelDocumentTypeDoclabelField < ActiveRecord::Migration
  def self.up
    change_table :model_document_types do |t|
      t.string :doc_label, :null => false, :default => 'default'
    end
    
    add_index :model_document_types, :doc_label
    add_index :model_document_types, [:model_type, :doc_label], :name => 'mod_docs_type_docid_label'
  end

  def self.down
    change_table :model_documents do |t|
      t.remove :doc_label
    end
  end
end