require 'test_helper'

class UserPermissionsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @user_permission = UserPermission.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_permissions)
  end
  
  test "autocomplete" do
    lookup_instance = UserPermission.make
    get :index, :name => lookup_instance.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @user_permission.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@user_permission.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_permission" do
    assert_difference('UserPermission.count') do
      post :create, :user_permission => { :name => 'some random name for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{user_permission_path(assigns(:user_permission))}$/
  end

  test "should show user_permission" do
    get :show, :id => @user_permission.to_param
    assert_response :success
  end

  test "should show user_permission with documents" do
    model_doc1 = ModelDocument.make(:documentable => @user_permission)
    model_doc2 = ModelDocument.make(:documentable => @user_permission)
    get :show, :id => @user_permission.to_param
    assert_response :success
  end
  
  test "should show user_permission with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @user_permission, :group => group
    group_member2 = GroupMember.make :groupable => @user_permission, :group => group
    get :show, :id => @user_permission.to_param
    assert_response :success
  end
  
  test "should show user_permission with audits" do
    Audit.make :auditable_id => @user_permission.to_param, :auditable_type => @user_permission.class.name
    get :show, :id => @user_permission.to_param
    assert_response :success
  end
  
  test "should show user_permission audit" do
    get :show, :id => @user_permission.to_param, :audit_id => @user_permission.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @user_permission.to_param
    assert_response :success
  end

  test "should update user_permission" do
    put :update, :id => @user_permission.to_param, :user_permission => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{user_permission_path(assigns(:user_permission))}$/
  end

  test "should destroy user_permission" do
    assert_difference('UserPermission.count', -1) do
      delete :destroy, :id => @user_permission.to_param
    end
  end
end
