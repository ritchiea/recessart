require 'test_helper'

class FundingSourceAllocationAuthoritiesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @funding_source_allocation_authority = FundingSourceAllocationAuthority.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:funding_source_allocation_authorities)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create funding_source_allocation_authority" do
    fsa = FundingSourceAllocation.make 
    mev = MultiElementValue.make
    assert_difference('FundingSourceAllocationAuthority.count') do
      post :create, :funding_source_allocation_authority => { :authority_id => mev.id, :funding_source_allocation_id => fsa.id }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{funding_source_allocation_authority_path(assigns(:funding_source_allocation_authority))}$/
  end

  test "should show funding_source_allocation_authority" do
    get :show, :id => @funding_source_allocation_authority.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @funding_source_allocation_authority.to_param
    assert_response :success
  end

  test "should update funding_source_allocation_authority" do
    put :update, :id => @funding_source_allocation_authority.to_param, :funding_source_allocation_authority => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{funding_source_allocation_authority_path(assigns(:funding_source_allocation_authority))}$/
  end

  test "should destroy funding_source_allocation_authority" do
    assert_difference('FundingSourceAllocationAuthority.count', -1) do
      delete :destroy, :id => @funding_source_allocation_authority.to_param
    end
  end
end
