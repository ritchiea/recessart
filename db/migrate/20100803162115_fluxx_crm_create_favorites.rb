class FluxxCrmCreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.timestamps
      t.integer :user_id, :null => true, :limit => 12
      t.string :favorable_type, :null => false
      t.integer :favorable_id, :null => false, :limit => 12
    end

    execute "alter table favorites add constraint favorites_user_id foreign key (user_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :favorites
  end
  
end