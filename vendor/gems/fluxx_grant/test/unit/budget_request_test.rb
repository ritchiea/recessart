require 'test_helper'

class BudgetRequestTest < ActiveSupport::TestCase
  def setup
    @budget_request = BudgetRequest.make
  end
  
  test "truth" do
    assert true
  end
end