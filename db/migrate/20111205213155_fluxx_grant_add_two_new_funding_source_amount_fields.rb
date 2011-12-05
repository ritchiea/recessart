class FluxxGrantAddTwoNewFundingSourceAmountFields < ActiveRecord::Migration
  def self.up
    change_table :funding_sources do |t|
      t.decimal :amount_requested, :scale => 2, :precision => 15
      t.decimal :amount_budgeted, :scale => 2, :precision => 15
    end
  end

  def self.down
    change_table :funding_sources do |t|
      t.remove :amount_requested
      t.remove :amount_budgeted
    end
  end
end