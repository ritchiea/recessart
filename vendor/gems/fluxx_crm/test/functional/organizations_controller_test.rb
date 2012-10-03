require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @org1 = Organization.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organizations)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:organizations)
  end


# TODO ESH: I put in a parent_org_id = 0 where clause for sphinx; may need to swizzle that to parent_org_id = nil and work out a way to make that 0 when it gets to sphinx for this test to pass
  test "autocomplete" do
    Organization.make
    lookup_org = Organization.make
    get :index, :name => lookup_org.name, :format => :autocomplete, :all_results => 1
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert_equal lookup_org.autocomplete_to_s, a.first['label']
    assert a.map{|elem| elem['value']}.include?(lookup_org.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @org1.name, :format => :autocomplete, :all_results => 1
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@org1.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create organization" do
    assert_difference('Organization.count') do
      post :create, :organization => { :name => 'some random name for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{organization_path(assigns(:organization))}$/
  end

  test "should show organization" do
    get :show, :id => @org1.to_param
    assert_response :success
  end

  test "should show organization with documents" do
    model_doc1 = ModelDocument.make(:documentable => @org1)
    model_doc2 = ModelDocument.make(:documentable => @org1)
    get :show, :id => @org1.to_param
    assert_response :success
  end
  
  test "should show organization with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @org1, :group => group
    group_member2 = GroupMember.make :groupable => @org1, :group => group
    get :show, :id => @org1.to_param
    assert_response :success
  end
  
  test "should show organization with notes" do
    note1 = Note.make(:notable => @org1)
    note2 = Note.make(:notable => @org1)
    get :show, :id => @org1.to_param
    assert_response :success
  end

  test "should show organization with bank accounts" do
    bank_account1 = BankAccount.make(:owner_organization => @org1)
    bank_account2 = BankAccount.make(:owner_organization => @org1)
    get :show, :id => @org1.to_param
    assert_response :success
  end
  
  test "should show organization with audits" do
    Audit.make :auditable_id => @org1.to_param, :auditable_type => @org1.class.name
    get :show, :id => @org1.to_param
    assert_response :success
  end
  
  test "should show organization audit" do
    get :show, :id => @org1.to_param, :audit_id => @org1.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @org1.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @org1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @org1.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @org1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @org1.to_param, :organization => {}
    assert assigns(:not_editable)
  end

  test "should update organization" do
    put :update, :id => @org1.to_param, :organization => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{organization_path(assigns(:organization))}$/
  end

  test "should destroy organization" do
    delete :destroy, :id => @org1.to_param
    assert_not_nil @org1.reload().deleted_at 
  end
  
  # TODO ESH: fix; currently show organizations doesn't do too much
  # test "should show organization with satellites" do
  #   get :show, :id => @org2.to_param
  # @org2 = Organization.make
  # @org3 = Organization.make(:parent_org => @org2)
  # @org4 = Organization.make(:parent_org => @org2)
  #   assert @response.body.index @org3.id.to_s
  #   assert @response.body.index @org4.id.to_s
  #   assert_response :success
  # end
  
  # TODO ESH: add a way in insta's rest interface to merge dupes
  # test "Check that we can merge two orgs" do
  #   login_as_user_with_role Role.data_cleanup_role_name, User
  #   good_org = Organization.make
  #   dupe_org = Organization.make
  #   put :merge_dupes, :base => good_org.id, :ids => "#{good_org.id}, #{dupe_org.id}"
  #   assert !(Organization.exists? dupe_org.id)
  # end
  # 
  # test "Check that we can merge two HQ orgs that have satellites" do
  #   login_as_user_with_role Role.data_cleanup_role_name, User
  #   @user_org = UserOrganization.make(:user => @user1, :organization => @org4)
  #   good_org = Organization.make
  #   good_org_sat = Organization.make :parent_org => good_org
  #   dupe_org = Organization.make
  #   dupe_org_sat = Organization.make :parent_org => dupe_org
  #   good_user = User.make
  #   dupe_user = User.make
  #   good_user_org = UserOrganization.make :user => good_user, :organization => good_org
  #   dupe_user_org = UserOrganization.make :user => dupe_user, :organization => dupe_org
  #   put :merge_dupes, :base => good_org.id, :ids => "#{good_org.id}, #{dupe_org.id}"
  #   assert !(Organization.exists? dupe_org.id)
  #   assert_equal 2, good_org.user_organizations.size
  #   assert_equal 2, good_org.has_satellites?
  # end
  # 
  # test "Should not be able to merge a HQ with satellites to a satellite" do
  #   login_as_user_with_role Role.data_cleanup_role_name, User
  #   good_org = Organization.make
  #   good_org_sat = Organization.make :parent_org => good_org
  #   dupe_org = Organization.make
  #   dupe_org_sat = Organization.make :parent_org => dupe_org
  #   put :merge_dupes, :base => good_org_sat.id, :ids => "#{good_org_sat.id}, #{dupe_org.id}"
  #   assert Organization.exists? dupe_org.id
  #   assert_equal 1, good_org.reload.has_satellites?
  #   assert_equal 1, dupe_org.reload.has_satellites?
  # end
  # 
  # test "Should not be able to link a satellite to its hq" do
  #   login_as_user_with_role Role.data_cleanup_role_name, User
  #   good_org = Organization.make
  #   sat_to_be = Organization.make
  #   put :link_satellites, :base => good_org.id, :ids => "#{good_org.id}, #{sat_to_be.id}"
  #   assert Organization.exists?(sat_to_be.id)
  #   assert_equal 1, good_org.reload.has_satellites?
  #   assert !sat_to_be.reload.has_satellites?
  # end
  
  
end
