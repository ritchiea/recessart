class FluxxCrmAddModelDocumentDocumentTypeField < ActiveRecord::Migration
  def self.up
    change_table :model_documents do |t|
      t.string :doc_label, :null => false, :default => 'default'
    end
    
    add_index :model_documents, :doc_label
    add_index :model_documents, [:documentable_type, :documentable_id, :doc_label], :name => 'mod_docs_type_docid_label'
  end

  def self.down
    change_table :model_documents do |t|
      t.remove :doc_label
    end
  end
end
