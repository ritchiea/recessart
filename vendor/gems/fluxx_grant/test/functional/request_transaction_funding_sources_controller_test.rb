require 'test_helper'

class RequestTransactionFundingSourcesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @RequestTransactionFundingSource = RequestTransactionFundingSource.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_transaction_funding_sources)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request_transaction_funding_source" do
    rfs = RequestFundingSource.make
    rt = RequestTransaction.make
    assert_difference('RequestTransactionFundingSource.count') do
      post :create, :request_transaction_funding_source => { :request_transaction_id => rt.id, :request_funding_source_id => rfs.id }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_transaction_funding_source_path(assigns(:request_transaction_funding_source))}$/
  end

  test "should show request_transaction_funding_source" do
    get :show, :id => @RequestTransactionFundingSource.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @RequestTransactionFundingSource.to_param
    assert_response :success
  end

  test "should update request_transaction_funding_source" do
    put :update, :id => @RequestTransactionFundingSource.to_param, :request_transaction_funding_source => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_transaction_funding_source_path(assigns(:request_transaction_funding_source))}$/
  end

  test "should destroy request_transaction_funding_source" do
    assert_difference('RequestTransactionFundingSource.count', -1) do
      delete :destroy, :id => @RequestTransactionFundingSource.to_param
    end
  end
end
