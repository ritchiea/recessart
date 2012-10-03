require 'test_helper'

class GeoStateTest < ActiveSupport::TestCase
  def setup
    @geo_state = GeoState.make
  end
  
  test "truth" do
    assert true
  end
end