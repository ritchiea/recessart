class FluxxGrantConvertAmountsToMoney < ActiveRecord::Migration
  def self.conversions
    {
      :budget_requests => %w[amount_requested amount_recommended],
      :funding_source_allocations => %w[amount],
      :funding_source_allocation_authorities => %w[amount],
      :funding_sources => %w[amount],
      :request_amendments => %w[amount_recommended],
      :request_funding_sources => %w[funding_amount],
      :request_transaction_funding_sources => %w[amount],
      :request_transactions => %w[amount_paid],
      :requests => %w[amount_requested amount_recommended funds_expended_amount],
    }
  end

  def self.up
    conversions.each { |table, fields|
      fields.each { |field| change_column table, field, :decimal, :scale => 2, :precision => 10 }
    }
  end

  def self.down
    conversions.each { |table, fields|
      fields.each { |field| change_colum table, field, :integer }
    }
  end
end
