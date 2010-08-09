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
    execute "alter table notes add constraint notes_created_by_id foreign key (created_by_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table notes add constraint notes_updated_by_id foreign key (updated_by_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :notes
  end
end
