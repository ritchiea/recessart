require 'test_helper'

class ProjectListItemsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @project_list_item1 = ProjectListItem.make
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_list_item" do
    assert_difference('ProjectListItem.count') do
      post :create, :project_list_item => { :name => 'some random title for you', :list_item_text => 'some random list item text for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{project_list_item_path(assigns(:project_list_item))}$/
  end

  test "should show project_list_item" do
    get :show, :id => @project_list_item1.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @project_list_item1.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @project_list_item1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @project_list_item1.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @project_list_item1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @project_list_item1.to_param, :project_list_item => {}
    assert assigns(:not_editable)
  end

  test "should update project_list_item" do
    put :update, :id => @project_list_item1.to_param, :project_list_item => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{project_list_item_path(assigns(:project_list_item))}$/
  end

  test "should destroy project_list_item" do
    delete :destroy, :id => @project_list_item1.to_param
    assert_not_nil @project_list_item1.reload().deleted_at 
  end
end
