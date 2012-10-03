require 'test_helper'

class LoiTest < ActiveSupport::TestCase
  def setup
    @loi = Loi.make
  end
  
  test "truth" do
    assert true
  end
end