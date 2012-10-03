require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  def setup
    @org = Organization.make
  end
  
  test "test creating organization" do
    assert @org.id
  end
end