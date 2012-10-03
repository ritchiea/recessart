class FluxxEngineCreateClientStores < ActiveRecord::Migration
  def self.up
    create_table :client_stores do |t|
      t.timestamps
      t.integer :user_id
      t.string :client_store_type
      t.string :name
      t.datetime :deleted_at,                :null => true
    end
    add_long_text_column :client_stores, :data
    add_index :client_stores, :user_id
    add_index :client_stores, [:user_id, :client_store_type]
  end

  def self.down
    drop_table :client_stores
  end
end