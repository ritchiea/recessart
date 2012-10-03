class CreateRaces < ActiveRecord::Migration
  def self.up
    create_table :races do |t|
      t.timestamps
      t.string :name
      t.string :state
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
    end
  end

  def self.down
    drop_table :races
  end
end
