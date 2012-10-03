require 'test_helper'

class ProjectListsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @project_list1 = ProjectList.make
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_list" do
    assert_difference('ProjectList.count') do
      post :create, :project_list => { :title => 'some random title for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{project_list_path(assigns(:project_list))}$/
  end

  test "should show project_list" do
    get :show, :id => @project_list1.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @project_list1.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @project_list1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @project_list1.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @project_list1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @project_list1.to_param, :project_list => {}
    assert assigns(:not_editable)
  end

  test "should update project_list" do
    put :update, :id => @project_list1.to_param, :project_list => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{project_list_path(assigns(:project_list))}$/
  end

  test "should destroy project_list" do
    delete :destroy, :id => @project_list1.to_param
    assert_not_nil @project_list1.reload().deleted_at 
  end
end
