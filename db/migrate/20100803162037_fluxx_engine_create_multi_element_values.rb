class FluxxEngineCreateMultiElementValues < ActiveRecord::Migration
  def self.up
    create_table :multi_element_values do |t|
      t.timestamps
      t.string :description, :length => 255
      t.string :value, :length => 255
      t.integer :multi_element_group_id, :null => true, :limit => 12
      t.integer :dependent_multi_element_value_id
    end
    add_index :multi_element_values, :multi_element_group_id
    add_constraint 'multi_element_values', 'multi_element_values_group_id', 'multi_element_group_id', 'multi_element_groups', 'id'
    add_constraint 'multi_element_values', 'multi_element_values_dependent_value_id', 'dependent_multi_element_value_id', 'multi_element_values', 'id'
  end

  def self.down
    drop_table :multi_element_values
  end
end