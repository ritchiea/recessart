require 'test_helper'

class ProjectListTest < ActiveSupport::TestCase
  def setup
    @project_list = ProjectList.make
  end

  test "truth" do
    assert true
  end
end