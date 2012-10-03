require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = Project.make
  end
  
  test "truth" do
    assert true
  end
end