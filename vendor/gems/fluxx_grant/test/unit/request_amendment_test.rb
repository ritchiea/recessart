require 'test_helper'

class RequestAmendmentTest < ActiveSupport::TestCase
  def setup
    @request_amendment = RequestAmendment.make
  end
  
  test "truth" do
    assert true
  end
end