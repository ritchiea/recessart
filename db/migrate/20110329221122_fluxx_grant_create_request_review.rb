class FluxxGrantCreateRequestReview < ActiveRecord::Migration
  def self.up
        create_table "request_reviews", :force => true do |t|
    t.timestamps
    t.integer :created_by_id, :updated_by_id, :request_id, :rating :null => true, :limit => 12
    t.string :review_type, :null => false, :default => 'RequestReport'
    t.text :comment, :benefits, :outcomes, :merits
    t.datetime :locked_until, :deleted_at, :null => true
  end

  add_constraint 'request_reviews', 'request_reviews_created_by_id', 'created_by_id', 'users', 'id'
  add_constraint 'request_reviews', 'request_reviews_updated_by_id', 'updated_by_id', 'users', 'id'
  end

  def self.down
    drop_table "request_reviews"
  end
end