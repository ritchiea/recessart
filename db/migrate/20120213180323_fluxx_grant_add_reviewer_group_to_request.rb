class FluxxGrantAddReviewerGroupToRequest < ActiveRecord::Migration
  def self.up
    change_table :requests do |t|
      t.integer :reviewer_group_id
    end
  end

  def self.down
    change_table :requests do |t|
      t.remove :reviewer_group_id
    end
  end
end