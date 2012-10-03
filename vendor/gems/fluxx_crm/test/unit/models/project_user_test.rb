require 'test_helper'

class ProjectUserTest < ActiveSupport::TestCase
  def setup
    @project_user = ProjectUser.make
  end

  test "truth" do
    assert true
  end
end