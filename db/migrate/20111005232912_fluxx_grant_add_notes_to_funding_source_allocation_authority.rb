class FluxxGrantAddNotesToFundingSourceAllocationAuthority < ActiveRecord::Migration
  def self.up
    change_table :funding_source_allocation_authorities do |t|
      t.text :note
    end
  end

  def self.down
    change_table :funding_source_allocation_authorities do |t|
      t.remove :note
    end
  end
end