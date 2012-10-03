require 'test_helper'

class GroupMembersControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @group_member1 = GroupMember.make
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group_member" do
    org = Organization.make
    group = Group.make
    assert_difference('GroupMember.count') do
      post :create, :group_member => { :group_id => group.id, :groupable_id => org.id, :groupable_type => group.class.name }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{group_member_path(assigns(:group_member))}$/
  end

  test "should show group_member" do
    get :show, :id => @group_member1.to_param
    assert_response :success
  end
  
  test "should show group_member audit" do
    get :show, :id => @group_member1.to_param, :audit_id => @group_member1.audits.first.to_param
    assert_response :success
  end

  test "should destroy group_member" do
    found_group_member = GroupMember.find @group_member1.to_param
    assert_difference('GroupMember.count', -1) do
      delete :destroy, :id => @group_member1.to_param
    end
  end
end
