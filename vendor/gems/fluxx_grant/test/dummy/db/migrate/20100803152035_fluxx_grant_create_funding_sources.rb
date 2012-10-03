class FluxxGrantCreateFundingSources < ActiveRecord::Migration
  def self.up
    create_table :funding_sources do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name
      t.integer :amount
    end
  end

  def self.down
    drop_table :funding_sources
  end
end