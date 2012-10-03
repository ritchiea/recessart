require 'test_helper'

class WorkTaskTest < ActiveSupport::TestCase
  def setup
    @work_task = WorkTask.make
  end
  
  test "truth" do
    assert true
  end
end