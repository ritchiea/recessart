require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
  end
  
  test "test to create then delete a role_user with no roleable" do
    user = User.make
    user.add_role 'president'
    assert_equal 1, user.role_users.size
    user.reload.has_role? 'president'
    user.remove_role 'president'
    assert_equal 0, user.role_users.size
  end
  
  test "test to create then delete a role_user with a roleable" do
    user = User.make
    org = Organization.make
    user.add_role 'president', org
    assert_equal 1, user.role_users.size
    user.reload.has_role? 'president', org
    user.remove_role 'president', org
    assert_equal 0, user.role_users.size
  end
  
  test "test that a role can be assigned and deleted" do
    new_user = User.make
    new_user.add_role 'president'
    new_user.reload.has_role? 'president'
    new_user.remove_role 'president'
    assert new_user.role_users.empty?
    assert !(new_user.reload.has_role? 'fred_role')
  end
  
  test "test that has_role works with multiple roles" do
    new_user = User.make
    (1..10).each {|i| new_user.add_role "fred_role_#{i}"}
    (1..10).each {|i| new_user.reload.has_role? "fred_role_#{i}"}
  end
  
  test "test that multiple instances of the same user object can update the role object successfully" do
    new_user = User.make
    user_1 = User.find new_user.id
    user_2 = User.find new_user.id
    user_1.add_role 'fred_role_1'
    assert user_1.has_role? 'fred_role_1'
    user_2.add_role 'fred_role_2'
    assert user_2.has_role? 'fred_role_1'
    assert user_2.has_role? 'fred_role_2'
    new_user.reload
    assert new_user.has_role? 'fred_role_1'
    assert new_user.has_role? 'fred_role_2'
  end

  # test "Check that we can merge two users that have assigned the same role" do
  #   good_user = User.make
  #   good_user.add_role 'role_good'
  #   dupe_user = User.make
  #   dupe_user.add_role 'role_dupe'
  #   good_user.merge dupe_user
  #   assert !(User.exists? dupe_user.id)
  #   assert good_user.has_role? 'role_dupe'
  # end
  # 
  # test "Check that we can merge two users that each are members of a particular group" do
  #   good_user_group = Group.make
  #   dupe_user_group = Group.make
  #   good_user = User.make
  #   dupe_user = User.make
  #   GroupMember.make :groupable => good_user, :groupable_type => User.name, :group => good_user_group
  #   GroupMember.make :groupable => dupe_user, :groupable_type => User.name, :group => dupe_user_group
  #   good_user.merge dupe_user
  #   assert !(User.exists? dupe_user.id)
  #   assert good_user.groups.include?(good_user_group)
  #   assert good_user.groups.include?(dupe_user_group)
  # end
  # 
  # test "Check that we can merge two users" do
  #   good_user = User.make
  #   dupe_user = User.make
  #   good_user.merge dupe_user
  #   assert !(User.exists? dupe_user.id)
  # end
  # 
  # test "Check that we can merge two users that created or modified notes" do
  #   good_user = User.make
  #   dupe_user = User.make
  #   note = Note.make :created_by => good_user, :updated_by => good_user
  #   assert_equal note.created_by_id, good_user.id
  #   assert_equal note.updated_by_id, good_user.id
  #   dup_note = Note.make :created_by => dupe_user, :updated_by => dupe_user
  #   assert_equal dup_note.created_by_id, dupe_user.id
  #   assert_equal dup_note.updated_by_id, dupe_user.id
  # 
  #   good_user.merge dupe_user
  #   assert !(User.exists? dupe_user.id)
  #   assert_equal 0, Note.count(:conditions => ['created_by_id = ?', dupe_user.id])
  #   assert_equal 2, Note.count(:conditions => ['created_by_id = ?', good_user.id])
  # end
  # 
  # test "Check that we can merge two users that have notes created about them" do
  #   good_user = User.make
  #   dupe_user = User.make
  #   note = Note.make :notable_type => User.name, :notable => good_user
  #   assert_equal note.notable_id, good_user.id
  #   dupe_note = Note.make :notable_type => User.name, :notable => dupe_user
  #   assert_equal dupe_note.notable_id, dupe_user.id
  # 
  #   good_user.merge dupe_user
  #   assert !(User.exists? dupe_user.id)
  #   assert_equal 0, Note.count(:conditions => ['notable_type = ? AND notable_id = ?', User.name, dupe_user.id])
  #   assert_equal 2, Note.count(:conditions => ['notable_type = ? AND notable_id = ?', User.name, good_user.id])
  # end
  # 
  # test "Check that we can merge two users where the dupe user has locked an org" do
  #   good_user = User.make
  #   dupe_user = User.make
  #   org = Organization.make :locked_by => dupe_user
  #   assert_equal org.locked_by_id, dupe_user.id
  # 
  #   good_user.merge dupe_user
  #   assert !(User.exists? dupe_user.id)
  #   assert_equal 0, Organization.count(:conditions => ['locked_by_id = ?', dupe_user.id])
  # end
  # 
  # test "Check that we can merge two users that have overlapping user orgs" do
  #   good_user = User.make
  #   dupe_user = User.make
  #   org = Organization.make
  #   good_user_org = UserOrganization.make :user => good_user, :organization => org
  #   dupe_user_org = UserOrganization.make :user => dupe_user, :organization => org
  #   assert good_user.merge dupe_user
  #   assert !(User.exists? dupe_user.id)
  #   assert !(UserOrganization.exists? dupe_user_org.id)
  #   assert UserOrganization.exists? good_user_org.id
  # end
  
  
  def setup_user_profile
    user_profile = UserProfile.make
    user = User.make :user_profile => user_profile
    [user_profile, user]
  end
  
  test "check that user_profile can set up the correct permissions for a user" do
    user_profile, user = setup_user_profile
    assert_equal user_profile, user.user_profile
    
    UserProfileRule.make :user_profile => user_profile, :permission_name => 'create', :model_type => Organization.name
    assert user.reload.has_create_for_model?(Organization)
  end
  
  test "check that a create_all privilege is respected" do
    employee_profile = UserProfile.make :name => 'Employee'
    UserProfileRule.make :user_profile => employee_profile, :permission_name => 'create_all'
    user = User.make :user_profile => employee_profile
    assert user.reload.has_create_for_model?(Organization)
  end
  test "check that has_create_for_own_model works for a user" do
    user_profile, user = setup_user_profile
    user.has_permission!('create_own', TestModel)
    assert user.reload.has_create_for_own_model?(TestModel)
  end

  test "check that has_create_for_model works for a user" do
    user_profile, user = setup_user_profile
    user.has_permission!('create', TestModel)
    assert user.has_create_for_model?(TestModel)
  end

  test "check that has_create_for_model works for a user using a string" do
    user_profile, user = setup_user_profile
    string_perm = 'some_crazy_model_type'
    user.has_permission!('create', string_perm)
    assert user.has_create_for_model?(string_perm)
  end

  test "check that has_update_for_own_model works for a user" do
    user_profile, user = setup_user_profile
    user.has_permission!('update_own', TestModel)
    assert user.has_update_for_own_model?(TestModel.new)
  end

  test "check that has_update_for_model works for a user" do
    user_profile, user = setup_user_profile
    user.has_permission!('update', TestModel)
    assert user.has_update_for_model?(TestModel.new)
  end

  test "check that has_delete_for_own_model works for a user" do
    user_profile, user = setup_user_profile
    user.has_permission!('delete_own', TestModel)
    assert user.has_delete_for_own_model?(TestModel.new)
  end

  test "check that has_delete_for_model works for a user" do
    user_profile, user = setup_user_profile
    user.has_permission!('delete', TestModel)
    assert user.has_delete_for_model?(TestModel.new)
  end

  test "check that has_listview_for_model works for a user" do
    user_profile, user = setup_user_profile
    user.has_permission!('listview', TestModel)
    assert user.has_listview_for_model?(TestModel)
  end
  
  test "check that has_view_for_own_model works for a user" do
    user_profile, user = setup_user_profile
    user.has_permission!('view_own', TestModel)
    assert user.has_view_for_own_model?(TestModel.new)
  end

  test "check that has_view_for_model works for a user" do
    user_profile, user = setup_user_profile
    user.has_permission!('view', TestModel)
    assert user.has_view_for_model?(TestModel.new)
  end

  test "check that has_view_for_own_model works for a user with subclass" do
    user_profile, user = setup_user_profile
    user.has_permission!('view_own', TestModel)
    assert user.has_view_for_own_model?(SubTestModel.new)
  end

  test "check that has_view_for_model works for a user with subclass" do
    user_profile, user = setup_user_profile
    user.has_permission!('view', TestModel)
    assert user.has_view_for_model?(SubTestModel.new)
  end
  
  test "check that we can add a user_rule with create_all and NOT create Organization and have it respect that.  Should still be able to create a TestModel" do
    user_profile, user = setup_user_profile
    UserProfileRule.create :user_profile => user_profile, :permission_name => 'create_all'
    UserProfileRule.create :user_profile => user_profile, :permission_name => 'create', :model_type => Organization.name, :allowed => false
    user.reload
    assert !user.reload.has_create_for_model?(Organization)
    assert user.reload.has_create_for_model?(TestModel)
  end
  
  test "check that we can add a user, remove it, then add a user with the same email" do
    an_email_address = random_email
    user = User.make :email => an_email_address
    user.delete
    user2 = User.make :email => an_email_address
    assert user2.id
    assert user.id != user2.id
  end
  
  test "check that we can add a user, remove it, then add a user with the same login" do
    a_login = random_login
    user = User.make :login => a_login
    user.delete
    user2 = User.make :login => a_login
    assert user2.id
    assert user.id != user2.id
  end
  
end

class TestModel
  def relates_to_user? user
    true
  end
end
  
class SubTestModel < TestModel
end
