require 'test_helper'

class GroupsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @group = Group.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end
  
  test "autocomplete" do
    get :index, :name => @group.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@group.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @group.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@group.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group" do
    assert_difference('Group.count') do
      post :create, :group => { :name => 'some random name for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{group_path(assigns(:group))}$/
  end

  test "should show group" do
    get :show, :id => @group.to_param
    assert_response :success
  end

  test "should show group with documents" do
    model_doc1 = ModelDocument.make(:documentable => @group)
    model_doc2 = ModelDocument.make(:documentable => @group)
    get :show, :id => @group.to_param
    assert_response :success
  end
  
  test "should show group with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @group, :group => group
    group_member2 = GroupMember.make :groupable => @group, :group => group
    get :show, :id => @group.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @group.to_param
    assert_response :success
  end

  test "should update group" do
    put :update, :id => @group.to_param, :group => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{group_path(assigns(:group))}$/
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete :destroy, :id => @group.to_param
    end
  end
end
