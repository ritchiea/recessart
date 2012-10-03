require 'test_helper'

class RolesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @Role = Role.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:roles)
  end

  test "autocomplete" do
    lookup_instance = Role.make
    get :index, :name => lookup_instance.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @Role.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@Role.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create role" do
    assert_difference('Role.count') do
      post :create, :role => { :name => 'some random name for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{role_path(assigns(:role))}$/
  end

  test "should show role" do
    get :show, :id => @Role.to_param
    assert_response :success
  end

  test "should show role with documents" do
    model_doc1 = ModelDocument.make(:documentable => @Role)
    model_doc2 = ModelDocument.make(:documentable => @Role)
    get :show, :id => @Role.to_param
    assert_response :success
  end
  
  test "should show role with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @Role, :group => group
    group_member2 = GroupMember.make :groupable => @Role, :group => group
    get :show, :id => @Role.to_param
    assert_response :success
  end
  
  test "should show role with audits" do
    Audit.make :auditable_id => @Role.to_param, :auditable_type => @Role.class.name
    get :show, :id => @Role.to_param
    assert_response :success
  end
  
  test "should show role audit" do
    get :show, :id => @Role.to_param, :audit_id => @Role.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @Role.to_param
    assert_response :success
  end

  test "should update role" do
    put :update, :id => @Role.to_param, :role => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{role_path(assigns(:role))}$/
  end

  test "should destroy role" do
    delete :destroy, :id => @Role.to_param
    assert @Role.reload.deleted_at
  end
end
