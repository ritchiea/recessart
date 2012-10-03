require 'test_helper'

class RequestUserTest < ActiveSupport::TestCase
  def setup
    @request_user = RequestUser.make
  end
  
  test "test creating request user" do
    assert @request_user.id
  end
end