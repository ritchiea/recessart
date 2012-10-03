class CreateMusicians < ActiveRecord::Migration
  def self.up
    create_table :musicians do |t|
      t.timestamps
      t.string :first_name
      t.string :last_name
      t.integer :music_type_id
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip
      t.datetime :date_of_birth
      t.integer :music_type_id
    end
  end

  def self.down
    drop_table :musicians
  end
end
