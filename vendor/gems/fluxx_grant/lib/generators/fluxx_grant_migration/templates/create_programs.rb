class FluxxGrantCreatePrograms < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name
      t.string :description
      t.integer :parent_id, :null => true, :limit => 12
      t.boolean :rollup
    end
    add_constraint 'programs', 'programs_parent_id', 'parent_id', 'programs', 'id'
    add_index :programs, :parent_id
  end

  def self.down
    drop_table :programs
  end
end