require 'test_helper'

class ProjectOrganizationTest < ActiveSupport::TestCase
  def setup
    @project_organization = ProjectOrganization.make
  end
  
  
  test "truth" do
    assert true
  end
end