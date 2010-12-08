class FluxxGrantCreateSubProgram < ActiveRecord::Migration
  def self.up
    create_table "sub_programs", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name,        :null => false
      t.text   :description, :null => true
      t.integer :initiative_id, :null => false, :limit => 12
    end
    add_index :sub_programs, :initiative_id
        
    add_constraint 'sub_programs', 'sub_programs_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'sub_programs', 'sub_programs_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'sub_programs', 'sub_program_initiative_id', 'initiative_id', 'initiatives', 'id'
  end

  def self.down
    drop_table "sub_programs"
  end
end