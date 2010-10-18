class FluxxGrantCreateInitiatives < ActiveRecord::Migration
  def self.up
    create_table :initiatives do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name
      t.string :description
      t.integer :program_id
    end
    add_index :initiatives, :program_id
    add_constraint 'initiatives', 'initiatives_program_id', 'program_id', 'programs', 'id'
  end

  def self.down
    drop_table :initiatives
  end
end