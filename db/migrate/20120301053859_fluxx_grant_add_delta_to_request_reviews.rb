class FluxxGrantAddDeltaToRequestReviews < ActiveRecord::Migration
  def self.up
    add_column :request_reviews, :delta, :boolean, :default => false
  end

  def self.down
    remove_column :request_reviews, :delta
  end
end