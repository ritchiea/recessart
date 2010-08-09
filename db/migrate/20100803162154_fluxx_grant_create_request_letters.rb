class FluxxGrantCreateRequestLetters < ActiveRecord::Migration
  def self.up
    create_table :request_letters do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :letter_template_id, :null => true, :limit => 12
      t.text :letter
      t.integer :locked_by_id, :null => true, :limit => 12
      t.datetime :locked_until, :deleted_at, :null => true
      t.boolean :delta, :null => false, :default => true
    end
    add_index :request_letters, :request_id
    add_index :request_letters, :letter_template_id
    execute "alter table request_letters add constraint request_letters_request_id foreign key (request_id) references requests(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table request_letters add constraint request_letters_letter_template_id foreign key (letter_template_id) references letter_templates(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :request_letters
  end
end