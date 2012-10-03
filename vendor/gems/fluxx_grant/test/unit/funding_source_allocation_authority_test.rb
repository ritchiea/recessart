require 'test_helper'

class FundingSourceAllocationAuthorityTest < ActiveSupport::TestCase
  def setup
    @funding_source_allocation_authority = FundingSourceAllocationAuthority.make
  end
  
  test "truth" do
    assert true
  end
end