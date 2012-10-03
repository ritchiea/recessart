require 'test_helper'

# LDAP Authentication test
# Fluxx LDAP Authentication functionality supports having both db and ldap users
# db users authenticate normally against the db with username/password
# ldap users authenticate against the ldap server, and the password will be nil in the fluxx db
# each time a ldap user logs in, some of their info will be synced (first name, last name, email)

# Questions:
# Fluxx validations may not support usernames etc used in external LDAP servers... how to approach?
#  => #<OrderedHash {:login=>["is too short (minimum is 6 characters)"]}> 
# Also, its possible for user to have 2 passwords, one in fluxx, one in ldap ... 

LDAP_CONFIG = {
  :host => "ldap.testathon.net",
  :port=> 389,
  :base=> "ou=users,dc=testathon,dc=net",
  :bind_dn=> "cn=stuart,ou=users,dc=testathon,dc=net",
  :password=> "stuart",
  :login_attr => 'cn',
  :first_name_attr => 'givenName',
  :last_name_attr => 'sn',
  :email_attr => 'mail'
}

class LdapUserTest < ActiveSupport::TestCase

  def setup
    # FLUXX_CONFIGURATION[:ldap_enabled] = true
    UserProfile.make :name => 'employee'
  end
  def enable_ldap
    Fluxx.expects(:config).with(:ldap_enabled).returns('1').at_least_once
  end
  def disable_ldap
    Fluxx.expects(:config).with(:ldap_enabled).returns(nil).at_least_once
  end
  
  # test 'Fluxx.config' do
  #   Thread.current[:fluxx_config] = nil
  #   FLUXX_CONFIGURATION[:ldap_enabled] = "1"
  #   assert_equal "1", Fluxx.config(:ldap_enabled)
  # end
  
  test 'should not call ldap methods if ldap is not enabled' do
    FLUXX_CONFIGURATION[:ldap_enabled] = false
    disable_ldap
    User.expects(:ldap_find).never
    User.expects(:create_or_update_user_from_ldap_entry).never
    assert_nil User.find_or_create_from_ldap('ldapuser')    
  end
  
  test 'should call ldap methods if ldap is enabled' do
    FLUXX_CONFIGURATION[:ldap_enabled] = true
    enable_ldap
    User.expects(:ldap_find).returns(setup_entry)
    User.expects(:create_or_update_user_from_ldap_entry)
    assert_nil User.find_or_create_from_ldap('ldapuser')    
  end

  test 'user created from ldap data if found in ldap' do
    enable_ldap
    entry = setup_entry
    User.expects(:ldap_find).returns(entry)
    user = User.find_or_create_from_ldap('ldapuser')
    assert_not_nil user
    assert_equal user.first_name, 'first'
    assert_equal user.last_name, 'last'
    assert_equal user.email, 'email@test.com'
    assert_equal user.user_profile.name, 'employee'
  end

  test 'stub LDAP.search' do
    enable_ldap
    entry = setup_entry
    Net::LDAP.any_instance.stubs(:search).returns([entry])
    assert_equal entry, User.ldap_find('foo')
  end  

  test "create_or_update_user_from_ldap_entry creates new user" do
    entry = setup_entry
    user = User.create_or_update_user_from_ldap_entry('username', entry)
    assert user.valid?
    assert !user.new_record?
    assert_not_nil User.find_by_login('username')
  end
  
  test "create_or_update_user_from_ldap_entry changed ldap user info updates db user" do
    entry = setup_entry
    User.create_or_update_user_from_ldap_entry('username', entry)
    db_user = User.find_by_login('username')
    # simulate ldap data change
    entry[LDAP_CONFIG[:first_name_attr]] = ['changed']
    User.create_or_update_user_from_ldap_entry('username', entry)
    db_user = User.find_by_login('username')
    assert_equal 'changed', db_user.first_name
  end


  test "create_or_update_user_from_ldap_entry local db user info reverts back to ldap" do
    entry = setup_entry
    User.create_or_update_user_from_ldap_entry('username', entry)
    db_user = User.find_by_login('username')
    # simulate local data change
    db_user.first_name = 'changed'
    db_user.save!
    db_user = User.find_by_login('username')
    assert_equal 'changed', db_user.first_name
    
    # revert to ldap 
    User.create_or_update_user_from_ldap_entry('username', entry)
    db_user = User.find_by_login('username')
    assert_equal 'first', db_user.first_name
  end

  test 'ldap_authenticate stub bind_as' do
    enable_ldap
    entry = setup_entry
    Net::LDAP.any_instance.stubs(:bind_as).returns([entry])
    user = User.create_or_update_user_from_ldap_entry('username', entry)    
    assert user.ldap_authenticate?('foo')
  end
  
  test 'ldap_authenticate (via valid_credentials) updates fluxx user info from ldap' do
    enable_ldap
    entry = setup_entry
    user = User.create_or_update_user_from_ldap_entry('username', entry)
    
    #simulate local data change
    user.first_name = 'changed'
    user.email = 'foo@test.com'
    user.save!
    
    # login will revert back to ldap values
    Net::LDAP.any_instance.stubs(:bind_as).returns([entry])
    user.valid_credentials?('foo') # b/c stub this password works
    user.reload
    assert_equal user.first_name, 'first'
    assert_equal user.email, 'email@test.com'
  end

  # create ldap entry that the ldap server responds with
  def setup_entry
    entry = {}
    entry[LDAP_CONFIG[:login_attr]] = ['username']
    entry[LDAP_CONFIG[:first_name_attr]] = ['first']
    entry[LDAP_CONFIG[:last_name_attr]] = ['last']
    entry[LDAP_CONFIG[:email_attr]] = ['email@test.com']
    entry
  end
  
end