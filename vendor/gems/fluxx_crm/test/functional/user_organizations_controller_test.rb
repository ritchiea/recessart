require 'test_helper'

class UserOrganizationsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @org1 = Organization.make
    @org2 = Organization.make
    @user_org1 = UserOrganization.make :organization => @org2, :user => @user1
  end
  
  test "should get new" do
    get :new, :user_id => @user1.id
    assert_response :success
  end
  
  test "should create user organization" do
    assert_difference('UserOrganization.count') do
      post :create, :user_organization => {:organization_id => @org1.id, :user_id => @user1.id}
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{user_organization_path(assigns(:user_organization))}$/
    
    assert_equal @org1, assigns(:user_organization).organization
    assert_equal @user1, assigns(:user_organization).user
  end

  test "should get edit" do
    get :edit, :id => @user_org1.id
    assert_response :success
  end

  test "should update organization" do
    @org3 = Organization.make

    put :update, :id => @user_org1.id, :user_organization => {:organization_id => @org3.id}
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{user_organization_path(assigns(:user_organization))}$/
    assert_equal @org3, assigns(:user_organization).organization
  end

  test "should not be able to add the same organization to the same user more than once" do
    post :create, :user_organization => {:organization_id => @org2.id, :user_id => @user1.id}

    assert_nil assigns(:user_organization).id
  end

  test "should not be able to update a user_org to be the same organization/user as an existing one" do
    @org4 = Organization.make
    @user_org2 = UserOrganization.make :organization => @org4, :user => @user1
    put :update, :id => @user_org2.id, :user_organization => {:organization_id => @org2.id, :user_id => @user1.id}
    
    assert_equal @org2.id, assigns(:user_organization).reload.organization_id
  end

  test "should destroy user_organization" do
    @org4 = Organization.make
    @user_org2 = UserOrganization.make :organization => @org4, :user => @user1
    assert_difference('UserOrganization.count', -1) do
      delete :destroy, :id => @user_org2.to_param
    end
    assert 201, @response.status
    # assert @response.header["Location"] =~ /#{user_organization_url(@user_org2)}$/
  end

  test "should destroy user_organization and primary user organization" do
    @org4 = Organization.make
    @user_org2 = UserOrganization.make :organization => @org4, :user => @user1
    @user1.update_attribute :primary_user_organization_id, @user_org2.id
    
    assert_difference('UserOrganization.count', -1) do
      delete :destroy, :id => @user_org2.to_param
    end
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{@user_org2.id}$/
    assert_equal @user_org1.id, @user1.reload.primary_user_organization_id
  end

  test "should not be allowed to edit if somebody else is editing" do
    @user_org1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @user_org1.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @user_org1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @user_org1.to_param, :organization => {}
    assert assigns(:not_editable)
  end
end
