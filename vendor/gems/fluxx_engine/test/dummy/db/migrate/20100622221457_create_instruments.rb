class CreateInstruments < ActiveRecord::Migration
  def self.up
    create_table :instruments do |t|
      t.timestamps
      t.string :name
      t.datetime :date_of_birth
      t.datetime :deleted_at
      t.integer :created_by_id
      t.integer :updated_by_id
      t.datetime :locked_until
      t.integer :locked_by_id
      t.integer :price
      t.integer :first_instrument_id
    end
  end

  def self.down
    drop_table :instruments
  end
end
