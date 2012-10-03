class FluxxGrantAddInitiativeIdToRequests < ActiveRecord::Migration
  def self.up
    change_table :requests do |t|
      t.integer :initiative_id
      t.integer :sub_initiative_id
    end
  end

  def self.down
    change_table :requests do |t|
      t.remove :initiative_id
      t.remove :sub_initiative_id
    end
  end
end