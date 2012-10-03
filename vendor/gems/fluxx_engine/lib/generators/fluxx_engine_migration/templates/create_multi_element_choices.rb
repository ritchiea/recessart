class FluxxEngineCreateMultiElementChoices < ActiveRecord::Migration
  def self.up
    create_table :multi_element_choices do |t|
      t.timestamps
      t.integer :target_id, :null => false, :limit => 12 # ID of the record this refers to; no foreign key relation unfortunately since we don't know which table it might be...
      t.integer :multi_element_value_id, :null => false, :limit => 12 # Note that this points to an element in multi_element_values which enforces the type, so we can derive the type of the class that target_id points to based on the multi_element_group that this multi_element_value points to
    end
    
    add_index :multi_element_choices, [:target_id, :multi_element_value_id], :unique => true, :name => 'multi_element_choices_index_cl_attr_val'
    add_constraint 'multi_element_choices', 'multi_element_choice_value_id', 'multi_element_value_id', 'multi_element_values', 'id'
  end

  def self.down
    drop_table :multi_element_choices
  end
end