require 'test_helper'

class RoleUsersControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @role_user = RoleUser.make :user => @user1, :role => Role.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:role_users)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:role_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create role_user" do
    assert_difference('RoleUser.count') do
      new_role = Role.make
      post :create, :role_user => { :user_id => @user1.to_param, :role_id => new_role.id }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{role_user_path(assigns(:role_user))}$/
    assert_equal @user1.id, assigns(:role_user).user_id
  end

  test "should show role_user" do
    get :show, :id => @role_user.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @role_user.to_param
    assert_response :success
  end

  test "should update role_user" do
    put :update, :id => @role_user.to_param, :role_user => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{role_user_path(assigns(:role_user))}$/
  end

  test "should destroy role_user" do
    assert_difference('RoleUser.count', -1) do
      delete :destroy, :id => @role_user.to_param
    end
  end
end
