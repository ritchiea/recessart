require 'test_helper'

class ProjectListItemTest < ActiveSupport::TestCase
  def setup
    @project_list_item = ProjectListItem.make
  end

  test "truth" do
    assert true
  end
end