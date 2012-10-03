require 'test_helper'

class RequestTransactionFundingSourceTest < ActiveSupport::TestCase
  def setup
    @request_transaction_funding_source = RequestTransactionFundingSource.make
  end
  
  test "truth" do
    assert true
  end
end