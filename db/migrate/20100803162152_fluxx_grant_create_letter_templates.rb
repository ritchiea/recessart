class FluxxGrantCreateLetterTemplates < ActiveRecord::Migration
  def self.up
    create_table :letter_templates do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :letter_type
      t.string :filename
      t.string :description
      t.string :category
      t.text :letter
      t.datetime :deleted_at, :null => true
      t.boolean :delta, :null => false, :default => true
    end
  end

  def self.down
    drop_table :letter_templates
  end
end