require 'test_helper'

class ProjectOrganizationsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @org = Organization.make
    @project = Project.make
    @project_organization1 = ProjectOrganization.make :organization_id => @org.id, :project_id => @project.id
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_organization" do
    assert_difference('ProjectOrganization.count') do
      post :create, :project_organization => { :organization_id => @org.id, :project_id => @project.id}
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{project_organization_path(assigns(:project_organization))}$/
  end

  test "should show project_organization" do
    get :show, :id => @project_organization1.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @project_organization1.to_param
    assert_response :success
  end

  test "should update project_organization" do
    put :update, :id => @project_organization1.to_param, :project_organization => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{project_organization_path(assigns(:project_organization))}$/
  end

  test "should destroy project_organization" do
    assert_difference('ProjectOrganization.count', -1) do
      delete :destroy, :id => @project_organization1.to_param
    end
  end
end
