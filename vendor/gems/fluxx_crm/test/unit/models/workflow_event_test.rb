require 'test_helper'

class WorkflowEventTest < ActiveSupport::TestCase
  def setup
    @workflow_event = WorkflowEvent.make
  end
  
  test "truth" do
    assert true
  end
end