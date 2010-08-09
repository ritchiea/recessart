class FluxxEngineCreateMultiElementValues < ActiveRecord::Migration
  def self.up
    create_table :multi_element_values do |t|
      t.timestamps
      t.string :description, :length => 255
      t.string :value, :length => 255
      t.integer :multi_element_group_id, :null => true, :limit => 12
    end
    add_index :multi_element_values, :multi_element_group_id
    execute "alter table multi_element_values add foreign key multi_element_values_group_id (multi_element_group_id) references multi_element_groups(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :multi_element_values
  end
end