class FluxxGrantAddStateToLois < ActiveRecord::Migration
  def self.up
    change_table :lois do |t|
      t.string :state
    end
  end

  def self.down
    change_table :lois do |t|
      t.remove :state
    end
  end
end