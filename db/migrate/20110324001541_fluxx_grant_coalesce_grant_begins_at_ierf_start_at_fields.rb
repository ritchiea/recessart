class FluxxGrantCoalesceGrantBeginsAtIerfStartAtFields < ActiveRecord::Migration
  def self.up
    execute 'update requests set grant_begins_at = ierf_start_at where grant_begins_at is null' rescue nil
    change_table :requests do |t|
      t.remove :ierf_start_at
    end rescue nil
  end

  def self.down
    change_table :requests do |t|
      t.datetime :ierf_start_at
    end
  end
end
