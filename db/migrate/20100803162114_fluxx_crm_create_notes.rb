class FluxxCrmCreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.text :note, :null => false
      t.string :notable_type, :null => false
      t.integer :notable_id, :null => false, :limit => 12
      t.boolean :delta,                      :null => :false, :default => true
      t.datetime :deleted_at,                :null => true
      t.datetime :locked_until,              :null => true
      t.integer :locked_by_id,               :null => true
    end
    add_index :notes, [:notable_type, :notable_id]
    add_constraint 'notes', 'notes_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'notes', 'notes_updated_by_id', 'updated_by_id', 'users', 'id'
  end

  def self.down
    drop_table :notes
  end
end
