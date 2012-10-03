require 'test_helper'

class RequestOrganizationTest < ActiveSupport::TestCase
  def setup
    @request_organization = RequestOrganization.make
  end
  
  test "test creating request organization" do
    assert @request_organization.id
  end
end