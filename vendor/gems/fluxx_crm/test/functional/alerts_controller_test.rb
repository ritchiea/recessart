require 'test_helper'

class AlertsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @alert = Alert.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alerts)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:alerts)
  end
  
  test "autocomplete" do
    lookup_instance = Alert.make
    get :index, :name => lookup_instance.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @alert.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@alert.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create alert" do
    assert_difference('Alert.count') do
      post :create, :alert => { :name => 'some random name for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{alert_path(assigns(:alert))}$/
  end

  test "should show alert" do
    get :show, :id => @alert.to_param
    assert_response :success
  end

  test "should show alert with documents" do
    model_doc1 = ModelDocument.make(:documentable => @alert)
    model_doc2 = ModelDocument.make(:documentable => @alert)
    get :show, :id => @alert.to_param
    assert_response :success
  end
  
  test "should show alert with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @alert, :group => group
    group_member2 = GroupMember.make :groupable => @alert, :group => group
    get :show, :id => @alert.to_param
    assert_response :success
  end
  
  test "should show alert with audits" do
    Audit.make :auditable_id => @alert.to_param, :auditable_type => @alert.class.name
    get :show, :id => @alert.to_param
    assert_response :success
  end
  
  test "should show alert audit" do
    get :show, :id => @alert.to_param, :audit_id => @alert.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @alert.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @alert.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @alert.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @alert.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @alert.to_param, :alert => {}
    assert assigns(:not_editable)
  end

  test "should update alert" do
    put :update, :id => @alert.to_param, :alert => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{alert_path(assigns(:alert))}$/
  end

  test "should destroy alert" do
    delete :destroy, :id => @alert.to_param
    assert !Alert.exists?(@alert.id)
  end
end
