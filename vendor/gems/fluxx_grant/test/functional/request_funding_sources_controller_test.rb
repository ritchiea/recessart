require 'test_helper'

class RequestFundingSourcesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @org = Organization.make
    @program = Program.make
    @request1 = GrantRequest.make :program => @program, :program_organization => @org, :base_request_id => nil
    @funding_source = FundingSourceAllocation.make
  end
  
  test "should get new" do
    get :new, :request_id => @request1.id
    assert_response :success
  end
  
  test "should create request funding source" do
    assert_difference('RequestFundingSource.count') do
      post :create, :request_funding_source => {:request_id => @request1.id, :funding_amount => 2133, :funding_source_allocation_id => @funding_source.id}
    end

    # Figure out how to determine a 201 and the options therein; some HTTP header in the @response object
    # assert_redirected_to user_organization_path(assigns(:user_organization))
    
    assert_equal @funding_source, assigns(:request_funding_source).funding_source_allocation
    assert_equal @request1, assigns(:request_funding_source).request
  end

  test "should get edit" do
    rfs = RequestFundingSource.make
    get :edit, :id => rfs.id
    assert_response :success
  end


  test "should get edit with program, subprogram, initiative, subinitiative" do
    program = Program.make
    sub_program = SubProgram.make :program => program
    initiative = Initiative.make :sub_program => sub_program
    sub_initiative = SubInitiative.make :initiative => initiative
    rfs = RequestFundingSource.make :program => program, :sub_program => sub_program, :initiative => initiative, :sub_initiative => sub_initiative
    get :edit, :id => rfs.id
    assert_response :success
  end

  test "should update organization" do
    rfs = RequestFundingSource.make
    put :update, :id => rfs.id, :request_funding_source => {:funding_source_allocation_id => @funding_source.id}
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_funding_source_path(assigns(:request_funding_source))}$/
    assert_equal @funding_source, assigns(:request_funding_source).funding_source_allocation
  end
  
  test "should destroy request_funding_source" do
    rfs = RequestFundingSource.make
    delete :destroy, :id => rfs.to_param
    assert_raises ActiveRecord::RecordNotFound do
      rfs.reload()
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_funding_source_path(:id => rfs.id)}$/
  end
  test "should destroy request_funding_source that has a request transaction funding source linked to it" do
    rfs = RequestFundingSource.make
    rt = RequestTransaction.make
    request_transaction_funding_source = RequestTransactionFundingSource.make :request_funding_source_id => rfs.id, :request_transaction => rt
    delete :destroy, :id => rfs.to_param
    assert_raises ActiveRecord::RecordNotFound do
      rfs.reload()
    end
    assert_raises ActiveRecord::RecordNotFound do
      request_transaction_funding_source.reload()
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_funding_source_path(:id => rfs.id)}$/
    
  end
  
  test "should not be allowed to edit if somebody else is editing" do
    rfs = RequestFundingSource.make
    rfs.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => rfs.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    rfs = RequestFundingSource.make
    rfs.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => rfs.to_param
    assert assigns(:not_editable)
  end

  test "should get funding sources list for given request" do
    get :index, :request_id => @request1.id
    assert_response :success
  end


end