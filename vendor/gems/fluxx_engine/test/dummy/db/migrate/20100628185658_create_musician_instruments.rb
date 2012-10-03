class CreateMusicianInstruments < ActiveRecord::Migration
  def self.up
    create_table :musician_instruments do |t|
      t.timestamps
      t.integer :musician_id
      t.integer :instrument_id
    end
  end

  def self.down
    drop_table :musician_instruments
  end
end
