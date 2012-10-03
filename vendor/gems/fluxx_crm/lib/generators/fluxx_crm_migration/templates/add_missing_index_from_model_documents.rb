class FluxxCrmAddMissingIndexFromModelDocuments < ActiveRecord::Migration
  def self.up
    add_index :model_documents, [:documentable_id, :documentable_type], :name => 'model_documents_docid_type'
  end

  def self.down
  end
end