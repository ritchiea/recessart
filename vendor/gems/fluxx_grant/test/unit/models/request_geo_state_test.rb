require 'test_helper'

class RequestGeoStateTest < ActiveSupport::TestCase
  def setup
    @request_geo_state = RequestGeoState.make
  end
  
  test "test creating request geo state" do
    assert @request_geo_state.id
  end
end