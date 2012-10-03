require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
  end
  
  test "should create user and link it to an org" do
    org = Organization.make
    assert_difference('User.count') do
      post :create, :user => { :first_name => 'some random name for you', :last_name => 'a last name', :email => 'Somerandomemail@somerandomemailaddress.com', :temp_organization_id => org.id }
    end
    new_user = assigns(:user)
    user_org = UserOrganization.where(['organization_id = ? AND user_id = ?', org.id, new_user.id]).first
    assert user_org
    assert_equal new_user.id, user_org.user_id
    assert_equal org.id, user_org.organization_id
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:users)
  end
  
end