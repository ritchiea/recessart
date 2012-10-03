class FluxxEngineCreateMultiElementGroups < ActiveRecord::Migration
  def self.up
    create_table :multi_element_groups do |t|
      t.timestamps
      t.string  :target_class_name, :null => false  # Name of the class this group refers to
      t.string :name
      t.string :description
    end
  end

  def self.down
    drop_table :multi_element_groups
  end
end