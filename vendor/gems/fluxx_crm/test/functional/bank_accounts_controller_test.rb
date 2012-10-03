require 'test_helper'

class BankAccountsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @BankAccount = BankAccount.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bank_accounts)
  end
  
  test "autocomplete" do
    lookup_instance = BankAccount.make
    get :index, :bank_name => lookup_instance.bank_name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :bank_name => @BankAccount.bank_name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@BankAccount.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bank_account" do
    assert_difference('BankAccount.count') do
      post :create, :bank_account => { :bank_name => 'some random name for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{bank_account_path(assigns(:bank_account))}$/
  end

  test "should show bank_account" do
    get :show, :id => @BankAccount.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @BankAccount.to_param
    assert_response :success
  end

  test "should update bank_account" do
    put :update, :id => @BankAccount.to_param, :bank_account => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{bank_account_path(assigns(:bank_account))}$/
  end

  test "should destroy bank_account" do
    assert_difference('BankAccount.count', -1) do
      delete :destroy, :id => @BankAccount.to_param
    end
  end
end
