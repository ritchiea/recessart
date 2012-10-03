require 'test_helper'

class GeoCitiesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @city = GeoCity.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:geo_cities)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:geo_cities)
  end

  test "autocomplete" do
    get :index, :name => @city.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert_equal @city.name, a.first['label']
    assert_equal @city.id, a.first['value']
  end

  test "should confirm that name_exists" do
    get :index, :name => @city.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert_equal @city.id, a.first['value']
  end
end
