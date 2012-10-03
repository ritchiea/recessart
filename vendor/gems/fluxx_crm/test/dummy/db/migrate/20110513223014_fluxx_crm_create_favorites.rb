class FluxxCrmCreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.timestamps
      t.integer :user_id, :null => true, :limit => 12
      t.string :favorable_type, :null => false
      t.integer :favorable_id, :null => false, :limit => 12
    end

    add_constraint 'favorites', 'favorites_user_id', 'user_id', 'users', 'id'
    add_index :favorites, [:favorable_type, :favorable_id]
  end

  def self.down
    drop_table :favorites
  end
  
end