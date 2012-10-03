require 'test_helper'

class RequestProgramTest < ActiveSupport::TestCase
  def setup
    @request_program = RequestProgram.make
  end
  
  test "truth" do
    assert true
  end
end