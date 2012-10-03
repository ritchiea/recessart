require 'test_helper'

class ProjectRequestTest < ActiveSupport::TestCase
  def setup
    @project_request = ProjectRequest.make
  end

  test "truth" do
    assert true
  end
end