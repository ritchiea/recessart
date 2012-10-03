require 'test_helper'

class RoleUserTest < ActiveSupport::TestCase
  def setup
  end
  
  test "test to create then delete a role_user with a roleable" do
    user = User.make
    org = Organization.make
    user.add_role 'president', org
    roles = RoleUser.find_by_roleable org
    assert_equal 1, roles.size
    assert_equal user, roles.first.user
  end
  
  
end