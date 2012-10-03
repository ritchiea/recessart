require 'test_helper'

class ProjectUsersControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @project = Project.make
    @project_user1 = ProjectUser.make :user_id => @user1.id, :project_id => @project.id
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_user" do
    assert_difference('ProjectUser.count') do
      post :create, :project_user => { :user_id => @user1.id, :project_id => @project.id}
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{project_user_path(assigns(:project_user))}$/
  end

  test "should show project_user" do
    get :show, :id => @project_user1.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @project_user1.to_param
    assert_response :success
  end

  test "should update project_user" do
    put :update, :id => @project_user1.to_param, :project_user => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{project_user_path(assigns(:project_user))}$/
  end

  test "should destroy project_user" do
    assert_difference('ProjectUser.count', -1) do
      delete :destroy, :id => @project_user1.to_param
    end
  end
end
