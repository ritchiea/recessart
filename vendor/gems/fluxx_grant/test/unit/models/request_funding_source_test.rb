require 'test_helper'

class RequestFundingSourceTest < ActiveSupport::TestCase
  def setup
    @request_funding_source = RequestFundingSource.make
  end
  
  test "test creating request funding source" do
    assert @request_funding_source.id
  end
end