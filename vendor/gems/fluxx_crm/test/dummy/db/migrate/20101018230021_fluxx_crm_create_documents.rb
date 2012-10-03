class FluxxCrmCreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_updated_at
    end
    
    add_constraint 'documents', 'documents_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'documents', 'documents_updated_by_id', 'updated_by_id', 'users', 'id'
  end

  def self.down
    drop_table :documents
  end
end
