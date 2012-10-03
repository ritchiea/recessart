require 'test_helper'

class UserPermissionTest < ActiveSupport::TestCase
  def setup
    @user_permission = UserPermission.make
  end
  
  test "truth" do
    assert true
  end
end