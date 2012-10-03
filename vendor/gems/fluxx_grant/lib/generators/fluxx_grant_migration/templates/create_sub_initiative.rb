class FluxxGrantCreateSubInitiative < ActiveRecord::Migration
  def self.up
    create_table "sub_initiatives", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name,        :null => false
      t.text   :description, :null => true
      t.integer :sub_program_id, :null => false, :limit => 12
    end
    
    add_constraint 'sub_initiatives', 'sub_initiatives_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'sub_initiatives', 'sub_initiatives_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'sub_initiatives', 'sub_initiative_sub_program_id', 'sub_program_id', 'sub_programs', 'id'
  end

  def self.down
    drop_table "sub_initiatives"
  end
end