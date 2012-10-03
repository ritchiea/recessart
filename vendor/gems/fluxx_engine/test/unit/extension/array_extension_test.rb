require 'test_helper'

class ArrayExtensionTest < ActiveSupport::TestCase
  def setup
    @array = [1, 2, 3, 4, 5, 6, 7]
  end

  test "try up_to element" do
    new_array = @array.up_to 4
    assert_equal 4, new_array.size
  end
  
  test "try down_to element" do
    new_array = @array.down_to 5
    assert_equal 3, new_array.size
  end
end