class FluxxGrantAddConflictFieldToRequestReviewsTable < ActiveRecord::Migration
  def self.up
    change_table :request_reviews do |t|
      t.boolean :conflict_reported
    end
  end

  def self.down
    change_table :request_reviews do |t|
      t.remove :conflict_reported
    end
  end
end