require 'test_helper'

class RealtimeUpdatesControllerTest < ActionController::TestCase
  setup do
    @user = User.make
    login_as @user
  end

  test "should return the timestamp" do
    get :index, :ts => true
    right_now = Time.now
    assert_response :success
    a = @response.body.de_json # try to deserialize the JSON to an array
    ts = a['ts']
    assert ts
    assert_equal right_now.year, Time.at(ts).year
  end
  
  test "should return the delta_feed" do
    @delta1 = RealtimeUpdate.make
    get :index, :last_id => 0
    assert_response :success
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert_equal 1, a['deltas'].size
    assert a['ts']
  end

  test "later date should not return any delta_feed records" do
    get :index, :ts => Time.now.tomorrow.to_i
    assert_response :success
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a['deltas'].blank?
  end

  test "get the timestamp, create a new record, then check to see that it shows up in the delta feed" do
    get :index, :ts => Time.now.yesterday.to_i
    assert_response :success
    a = @response.body.de_json # try to deserialize the JSON to an array
    last_id = a['last_id']
    
    Musician.make 
    
    get :index, :last_id => (last_id.to_i - 1) # Simulate 1 second passing by
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert_equal 1, a['deltas'].size
  end
end