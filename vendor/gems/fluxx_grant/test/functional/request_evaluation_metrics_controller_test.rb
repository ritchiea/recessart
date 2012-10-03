require 'test_helper'

class RequestEvaluationMetricsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @request1 = GrantRequest.make 
  end
  
  test "should get new" do
    get :new, :request_id => @request1.id
    assert_response :success
  end
  
  test "should create request evaluation metric" do
    assert_difference('RequestEvaluationMetric.count') do
      post :create, :request_evaluation_metric => {:request_id => @request1.id, :description => Sham.sentence}
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_evaluation_metric_path(assigns(:request_evaluation_metric))}$/
    assert_equal @request1, assigns(:request_evaluation_metric).request
  end

  test "should get edit" do
    rem = RequestEvaluationMetric.make
    get :edit, :id => rem.id
    assert_response :success
  end

  test "should update organization" do
    rem = RequestEvaluationMetric.make
    put :update, :id => rem.id, :request_evaluation_metric => {:description => 'hello'}
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_evaluation_metric_path(assigns(:request_evaluation_metric))}$/
    assert_equal 'hello', assigns(:request_evaluation_metric).description
  end
  
  test "should destroy request_evaluation_metric" do
    rem = RequestEvaluationMetric.make
    delete :destroy, :id => rem.to_param
    assert_raises ActiveRecord::RecordNotFound do
      rem.reload()
    end
    assert 201, @response.status
    
    assert @response.header["Location"] =~ /#{request_evaluation_metric_path(:id => rem.id)}/
  end
  
  test "should get request evaluation metrics list for given request" do
    get :index, :request_id => @request1.id
    assert_response :success
  end


end