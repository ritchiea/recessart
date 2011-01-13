class FluxxGrantAddSpendingYearToFundingSourceAllocation < ActiveRecord::Migration
  def self.up
    add_column :funding_source_allocations, :spending_year, :integer
  end

  def self.down
    remove_column :funding_source_allocations, :spending_year
  end
end