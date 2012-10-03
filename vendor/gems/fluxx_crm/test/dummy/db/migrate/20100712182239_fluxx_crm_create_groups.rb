class FluxxCrmCreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.timestamps
      t.integer :created_by_id
      t.integer :updated_by_id
      t.string :name
      t.boolean :deprecated, :default => 0
    end
    add_index :groups, :name, :unique => true
  end

  def self.down
    drop_table :groups
  end
end
