require 'test_helper'

class FundingSourceAllocationTest < ActiveSupport::TestCase
  def setup
    @funding_source_allocation = FundingSourceAllocation.make
  end
  
  test "test validation of funding source allocation" do
    fsa = FundingSourceAllocation.create 
    assert !fsa.errors.empty?
    assert fsa.errors[:spending_year]
    assert fsa.errors[:amount]
    assert fsa.errors[:funding_source]
    assert fsa.errors[:authority]
  end
end