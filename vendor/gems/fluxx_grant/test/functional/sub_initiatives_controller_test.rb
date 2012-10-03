require 'test_helper'

class SubInitiativesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @SubInitiative = SubInitiative.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sub_initiatives)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sub_initiative" do
    assert_difference('SubInitiative.count') do
      post :create, :sub_initiative => { :name => 'some random name for you', :initiative_id => 1 }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{sub_initiative_path(assigns(:sub_initiative))}$/
  end

  test "should show sub_initiative" do
    get :show, :id => @SubInitiative.to_param
    assert_response :success
  end

  test "should show sub_initiative with documents" do
    model_doc1 = ModelDocument.make(:documentable => @SubInitiative)
    model_doc2 = ModelDocument.make(:documentable => @SubInitiative)
    get :show, :id => @SubInitiative.to_param
    assert_response :success
  end
  
  test "should show sub_initiative with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @SubInitiative, :group => group
    group_member2 = GroupMember.make :groupable => @SubInitiative, :group => group
    get :show, :id => @SubInitiative.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @SubInitiative.to_param
    assert_response :success
  end

  test "should update sub_initiative" do
    put :update, :id => @SubInitiative.to_param, :sub_initiative => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{sub_initiative_path(assigns(:sub_initiative))}$/
  end

  test "should destroy sub_initiative" do
    assert_difference('SubInitiative.count', -1) do
      delete :destroy, :id => @SubInitiative.to_param
    end
  end
end
