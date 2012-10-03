require 'test_helper'

class FundingSourcesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @FundingSource = FundingSource.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:funding_sources)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:funding_sources)
  end

  test "autocomplete" do
    lookup_instance = FundingSource.make
    get :index, :name => lookup_instance.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @FundingSource.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert_equal @FundingSource.id, a.first['value']
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create funding_source" do
    assert_difference('FundingSource.count') do
      post :create, :funding_source => { :name => 'some random name for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{funding_source_path(assigns(:funding_source))}$/
  end

  test "should show funding_source" do
    get :show, :id => @FundingSource.to_param
    assert_response :success
  end

  test "should show funding_source with documents" do
    model_doc1 = ModelDocument.make(:documentable => @FundingSource)
    model_doc2 = ModelDocument.make(:documentable => @FundingSource)
    get :show, :id => @FundingSource.to_param
    assert_response :success
  end
  
  test "should show funding_source with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @FundingSource, :group => group
    group_member2 = GroupMember.make :groupable => @FundingSource, :group => group
    get :show, :id => @FundingSource.to_param
    assert_response :success
  end
  
  test "should show funding_source with audits" do
    Audit.make :auditable_id => @FundingSource.to_param, :auditable_type => @FundingSource.class.name
    get :show, :id => @FundingSource.to_param
    assert_response :success
  end
  
  test "should show funding_source audit" do
    get :show, :id => @FundingSource.to_param, :audit_id => @FundingSource.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @FundingSource.to_param
    assert_response :success
  end

  test "should update funding_source" do
    put :update, :id => @FundingSource.to_param, :funding_source => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{funding_source_path(assigns(:funding_source))}$/
  end

  test "should destroy funding_source" do
    assert_difference('FundingSource.count', -1) do
      delete :destroy, :id => @FundingSource.to_param
    end
  end
end
