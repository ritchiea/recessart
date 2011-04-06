class FluxxGrantCreateBudgetRequest < ActiveRecord::Migration
  def self.up
    create_table :budget_requests do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :null => false, :limit => 12
      t.integer :amount_requested, :amount_recommended, :null => true, :limit => 12
      t.string :name, :null => true
      t.datetime :deleted_at,                :null => true
      t.datetime :locked_until,              :null => true
      t.integer :locked_by_id,               :null => true
    end
    add_index :budget_requests, [:request_id]
    add_constraint 'budget_requests', 'budget_requests_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'budget_requests', 'budget_requests_updated_by_id', 'updated_by_id', 'users', 'id'
  end

  def self.down
    drop_table :budget_requests
  end
end