require 'test_helper'

class GeoCountryTest < ActiveSupport::TestCase
  def setup
    @geo_country = GeoCountry.make
    @geo_state = GeoState.make :geo_country => @geo_country
  end
  
  test "make sure that the geo_state relates to the correct country" do
    assert_equal @geo_country, @geo_state.geo_country
  end
end