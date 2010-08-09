class FluxxGrantCreateInitiatives < ActiveRecord::Migration
  def self.up
    create_table :initiatives do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name
      t.string :description
      t.integer :program_id
    end
    add_index :initiatives, :program_id
    execute "alter table initiatives add constraint initiatives_program_id foreign key (program_id) references programs(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :initiatives
  end
end