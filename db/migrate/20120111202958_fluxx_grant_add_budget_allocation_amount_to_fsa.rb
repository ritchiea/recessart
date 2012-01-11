class FluxxGrantAddBudgetAllocationAmountToFsa < ActiveRecord::Migration
  def self.up
    change_table :funding_source_allocations do |t|
      t.decimal :budget_amount, :scale => 2, :precision => 15
    end
  end

  def self.down
    change_table :funding_source_allocations do |t|
      t.remove :budget_amount
    end
  end
end