class FluxxEngineCreateClientStores < ActiveRecord::Migration
  def self.up
    create_table :client_stores do |t|
      t.timestamps
      t.integer :user_id
      t.string :name
      t.datetime :deleted_at,                :null => true
    end
    if connection.adapter_name =~ /mysql/i
      execute 'ALTER TABLE client_stores ADD COLUMN data longtext collate utf8_unicode_ci' 
    else
      add_column :client_stores, :data, :text
    end
    
    add_index :client_stores, :user_id
    add_index :client_stores, [:user_id, :name], :unique => true
  end

  def self.down
    drop_table :client_stores
  end
end