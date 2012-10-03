require 'test_helper'

class BudgetRequestsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @budget_request = BudgetRequest.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:budget_requests)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:budget_requests)
  end
  
  test "autocomplete" do
    lookup_instance = BudgetRequest.make
    get :index, :name => lookup_instance.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @budget_request.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@budget_request.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create budget_request" do
    assert_difference('BudgetRequest.count') do
      post :create, :budget_request => { :name => 'some random name for you', :request_id => 1 }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{budget_request_path(assigns(:budget_request))}$/
  end

  test "should show budget_request" do
    get :show, :id => @budget_request.to_param
    assert_response :success
  end

  test "should show budget_request with documents" do
    model_doc1 = ModelDocument.make(:documentable => @budget_request)
    model_doc2 = ModelDocument.make(:documentable => @budget_request)
    get :show, :id => @budget_request.to_param
    assert_response :success
  end
  
  test "should show budget_request with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @budget_request, :group => group
    group_member2 = GroupMember.make :groupable => @budget_request, :group => group
    get :show, :id => @budget_request.to_param
    assert_response :success
  end
  
  test "should show budget_request with audits" do
    Audit.make :auditable_id => @budget_request.to_param, :auditable_type => @budget_request.class.name
    get :show, :id => @budget_request.to_param
    assert_response :success
  end
  
  test "should show budget_request audit" do
    get :show, :id => @budget_request.to_param, :audit_id => @budget_request.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @budget_request.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @budget_request.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @budget_request.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @budget_request.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @budget_request.to_param, :budget_request => {}
    assert assigns(:not_editable)
  end

  test "should update budget_request" do
    put :update, :id => @budget_request.to_param, :budget_request => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{budget_request_path(assigns(:budget_request))}$/
  end

  test "should destroy budget_request" do
    delete :destroy, :id => @budget_request.to_param
    assert_not_nil @budget_request.reload().deleted_at 
  end
end
