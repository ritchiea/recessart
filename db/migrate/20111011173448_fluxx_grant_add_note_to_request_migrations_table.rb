class FluxxGrantAddNoteToRequestMigrationsTable < ActiveRecord::Migration
  def self.up
    change_table :request_amendments do |t|
      t.text :note
    end
  end

  def self.down
    change_table :request_amendments do |t|
      t.remove :note
    end
  end
end