require 'test_helper'

class FixnumExtensionTest < ActiveSupport::TestCase
  def setup
  end

  test "try to_currency" do
    assert_equal "$542.00", 542.to_currency
  end
  
  test "try to_currency_no_cents" do
    assert_equal "$542", 542.to_currency_no_cents
  end
end