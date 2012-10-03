require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  def setup
    @role = Role.make
  end
  
  test "truth" do
    assert true
  end
end