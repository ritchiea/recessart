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
    add_constraint 'request_letters', 'request_letters_request_id', 'request_id', 'requests', 'id'
    add_constraint 'request_letters', 'request_letters_letter_template_id', 'letter_template_id', 'letter_templates', 'id'
  end

  def self.down
    drop_table :request_letters
  end
end