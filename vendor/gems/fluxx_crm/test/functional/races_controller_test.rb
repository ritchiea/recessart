require 'test_helper'

class RacesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @race = Race.make
  end
  
  test "should show race" do
    get :show, :id => @race.to_param
    assert_response :success
    assert assigns(:action_buttons)
    assert assigns(:action_buttons).include?([:kick_off, "Kick Off"])
  end
  
  test "should update user" do
    assert_equal 'new', @race.state
    put :update, :id => @race.to_param, :event_action => 'kick_off', :race => {}
    assert flash[:info]
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{race_path(assigns(:race))}$/
    assert_equal 'beginning', @race.reload.state
  end
  
  test "test reject" do
    assert_equal 'new', @race.state
    put :update, :id => @race.to_param, :event_action => 'reject', :race => {}
    assert flash[:info]
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{race_path(assigns(:race))}$/
    assert_equal 'rejected', @race.reload.state
  end
  
  test "should generate a workflow event" do
    race = Race.make
    assert_equal 'new', race.state
    assert_difference('WorkflowEvent.count') do
      race.kick_off
      assert_equal 'beginning', race.state
      race.save
    end
    
  end
  
end