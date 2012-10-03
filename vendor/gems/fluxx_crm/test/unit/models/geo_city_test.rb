require 'test_helper'

class GeoCityTest < ActiveSupport::TestCase
  def setup
    @geo_city = GeoCity.make
  end
  
  test "truth" do
    assert true
  end
end