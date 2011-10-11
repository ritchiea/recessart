class FluxxGrantAddStateToRequestAmendmentsTable < ActiveRecord::Migration
  def self.up
    change_table :request_amendments do |t|
      t.string :state
    end
  end

  def self.down
    change_table :request_amendments do |t|
      t.remove :state
    end
  end
end