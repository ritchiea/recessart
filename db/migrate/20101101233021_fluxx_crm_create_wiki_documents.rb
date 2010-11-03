class FluxxCrmCreateWikiDocuments < ActiveRecord::Migration
  def self.up
    create_table :wiki_documents do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :model_id, :limit => 12
      t.string :model_type
      t.integer :wiki_order   # order in which the wiki entries are displayed
      t.string :title
      t.text :note
      t.datetime :deleted_at,                :null => true
      t.datetime :locked_until,              :null => true
      t.integer :locked_by_id,               :null => true
    end

    add_constraint 'wiki_documents', 'wiki_documents_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'wiki_documents', 'wiki_documents_updated_by_id', 'updated_by_id', 'users', 'id'
  end

  def self.down
    drop_table :wiki_documents
  end
end
