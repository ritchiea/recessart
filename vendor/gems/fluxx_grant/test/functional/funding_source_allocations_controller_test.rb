require 'test_helper'

class FundingSourceAllocationsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @funding_source_allocation = FundingSourceAllocation.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:funding_source_allocations)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create funding_source_allocation" do
    funding_source = FundingSource.make
    assert_difference('FundingSourceAllocation.count') do
      post :create, :funding_source_allocation => { :funding_source_id => funding_source.id, :amount => 1234, :spending_year => 2004 }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{funding_source_allocation_path(assigns(:funding_source_allocation))}$/
  end

  test "should show funding_source_allocation" do
    get :show, :id => @funding_source_allocation.to_param
    assert_response :success
  end

  test "should show funding_source_allocation with documents" do
    model_doc1 = ModelDocument.make(:documentable => @funding_source_allocation)
    model_doc2 = ModelDocument.make(:documentable => @funding_source_allocation)
    get :show, :id => @funding_source_allocation.to_param
    assert_response :success
  end
  
  test "should show funding_source_allocation with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @funding_source_allocation, :group => group
    group_member2 = GroupMember.make :groupable => @funding_source_allocation, :group => group
    get :show, :id => @funding_source_allocation.to_param
    assert_response :success
  end
  
  test "autocomplete" do
    lookup_funding_source_allocation = FundingSourceAllocation.make
    get :index, :format => :autocomplete
    assert_response :success
  end
  
  test "autocomplete with enough balance" do
    program = Program.make
    lookup_funding_source_allocation = FundingSourceAllocation.make :amount => 150000, :program_id => program.id, :spending_year => 2011
    lookup_funding_source_allocation_authority = FundingSourceAllocationAuthority.make :funding_source_allocation => lookup_funding_source_allocation, :amount => 150000
    
    get :index, :format => :autocomplete, :funding_amount => 50000, :program_id => program.id, :spending_year => 2011
    assert_response :success
    assert @response.body.index("#{lookup_funding_source_allocation.amount_remaining.to_currency}")
  end
  
  test "autocomplete without enough balance" do
    program = Program.make
    lookup_funding_source_allocation = FundingSourceAllocation.make :amount => 150000, :program_id => program.id, :spending_year => 2011
    lookup_funding_source_allocation_authority = FundingSourceAllocationAuthority.make :funding_source_allocation => lookup_funding_source_allocation, :amount => 150000
    get :index, :format => :autocomplete, :funding_amount => 250000, :program_id => program.id, :spending_year => 2011
    assert_response :success
    assert_equal '[]', @response.body
  end
  
  test "should show funding_source_allocation with audits" do
    Audit.make :auditable_id => @funding_source_allocation.to_param, :auditable_type => @funding_source_allocation.class.name
    get :show, :id => @funding_source_allocation.to_param
    assert_response :success
  end
  
  test "should show funding_source_allocation audit" do
    get :show, :id => @funding_source_allocation.to_param, :audit_id => @funding_source_allocation.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @funding_source_allocation.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @funding_source_allocation.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @funding_source_allocation.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @funding_source_allocation.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @funding_source_allocation.to_param, :funding_source_allocation => {}
    assert assigns(:not_editable)
  end

  test "should update funding_source_allocation" do
    put :update, :id => @funding_source_allocation.to_param, :funding_source_allocation => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{funding_source_allocation_path(assigns(:funding_source_allocation))}$/
  end

  test "should destroy funding_source_allocation" do
    delete :destroy, :id => @funding_source_allocation.to_param
    assert_not_nil @funding_source_allocation.reload().deleted_at 
  end
end
