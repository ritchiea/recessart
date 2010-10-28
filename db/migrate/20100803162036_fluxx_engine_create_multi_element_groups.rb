class FluxxEngineCreateMultiElementGroups < ActiveRecord::Migration
  def self.up
    create_table :multi_element_groups do |t|
      t.timestamps
      t.string  :target_class_name, :null => false  # Name of the class this group refers to
      t.string :name
      t.integer :dependent_multi_element_group_id
      t.string :description
    end
    add_constraint 'multi_element_groups', 'multi_element_groups_dependent_grp_id', 'dependent_multi_element_group_id', 'multi_element_groups', 'id'
  end

  def self.down
    drop_table :multi_element_groups
  end
end