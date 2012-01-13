class FluxxGrantAddActualBudgetAmountToFsa < ActiveRecord::Migration
  def self.up
    change_table :funding_source_allocations do |t|
      t.decimal :actual_budget_amount, :scale => 2, :precision => 15
    end
  end

  def self.down
    change_table :funding_source_allocations do |t|
      t.remove :actual_budget_amount
    end
  end
end