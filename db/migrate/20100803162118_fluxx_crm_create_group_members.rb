class FluxxCrmCreateGroupMembers < ActiveRecord::Migration
  def self.up
    create_table :group_members do |t|
      t.timestamps
      t.integer :created_by_id
      t.integer :updated_by_id
      t.integer :group_id
      t.integer :groupable_id
      t.string :groupable_type
    end
    add_index :group_members, :group_id
    add_index :group_members, [:groupable_id, :groupable_type]
    add_constraint 'group_members', 'group_members_group_id', 'group_id', 'groups', 'id'
  end

  def self.down
    drop_table :group_members
  end
end
