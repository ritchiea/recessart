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
    execute "alter table group_members add constraint group_members_group_id foreign key (group_id) references groups(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :group_members
  end
end
