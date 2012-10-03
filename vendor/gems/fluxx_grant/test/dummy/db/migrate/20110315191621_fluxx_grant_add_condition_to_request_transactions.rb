class FluxxGrantAddConditionToRequestTransactions < ActiveRecord::Migration
  def self.up
    add_column :request_transactions, :condition, :text
  end

  def self.down
    remove_column :request_transactions, :condition
  end
end