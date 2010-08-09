class FluxxCrmCreateModelDocuments < ActiveRecord::Migration
  def self.up
    create_table :model_documents do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_updated_at
      t.string :documentable_type, :null => false
      t.integer :documentable_id, :null => false, :limit => 12
      t.datetime :locked_until,              :null => true
      t.integer :locked_by_id,               :null => true
    end
  end

  def self.down
    drop_table :geo_cities
  end
end
