require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "autocomplete" do
    User.make
    lookup_user = User.make
    get :index, :first_name => lookup_user.first_name, :last_name => lookup_user.last_name, :format => :autocomplete, :all_results => 1
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert_equal lookup_user.to_s, a.first['label']
    assert a.map{|elem| elem['value']}.include?(lookup_user.id)
  end

  test "should confirm that user_exists" do
    get :index, :first_name => @user1.first_name, :format => :autocomplete, :all_results => 1
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@user1.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, :user => { :first_name => 'some random name for you', :last_name => 'a last name', :email => 'Somerandomemail@somerandomemailaddress.com' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{user_path(assigns(:user))}$/
  end

  test "create user should give a validation error with a non-unique email address" do
    assert_difference('User.count', 0) do
      post :create, :user => { :first_name => 'some random name for you', :last_name => 'a last name', :email => @user1.email }
    end

    assert !assigns(:model).errors.empty?
  end

  test "should show user" do
    get :show, :id => @user1.to_param
    assert_response :success
  end
  
  test "should show user audit" do
    get :show, :id => @user1.to_param, :audit_id => @user1.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @user1.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @user1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @user1.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @user1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @user1.to_param, :user => {}
    assert assigns(:not_editable)
  end

  test "should update user" do
    put :update, :id => @user1.to_param, :user => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{user_path(assigns(:user))}$/
  end

  test "should destroy user" do
    delete :destroy, :id => @user1.to_param
    assert_not_nil @user1.reload().deleted_at 
  end
end
