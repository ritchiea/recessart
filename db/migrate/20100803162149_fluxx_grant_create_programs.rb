class FluxxGrantCreatePrograms < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name
      t.string :description
      t.integer :parent_id, :null => true, :limit => 12
      t.boolean :rollup
    end
    execute "alter table programs add constraint programs_parent_id foreign key (parent_id) references programs(id)" unless connection.adapter_name =~ /SQLite/i
    add_index :programs, :parent_id
  end

  def self.down
    drop_table :programs
  end
end