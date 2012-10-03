require 'test_helper'

class RoleUsersControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @role_user = RoleUser.make :user => @user1, :role => Role.make
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create role_user" do
    assert_difference('RoleUser.count') do
      new_role = Role.make
      post :create, :role_user => { :user_id => @user1.to_param, :role_id => new_role.to_param }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{role_user_path(assigns(:role_user))}$/
    assert_equal @user1.id, assigns(:role_user).user_id
  end

  test "should get edit" do
    get :edit, :id => @role_user.to_param
    assert_response :success
  end
end
