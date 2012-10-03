class CreateOrchestras < ActiveRecord::Migration
  def self.up
    create_table :orchestras do |t|
      t.timestamps
      t.string :name
      t.datetime :locked_until
      t.integer :locked_by_id
    end
  end

  def self.down
    drop_table :orchestras
  end
end
