require 'test_helper'

class FundingSourceTest < ActiveSupport::TestCase
  def setup
    @funding_source = FundingSource.make
  end
  
  test "test creating funding source" do
    assert @funding_source.id
  end
end