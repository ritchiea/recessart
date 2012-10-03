require 'test_helper'

class AdminCardsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
  end
  
  test "should show admin_card" do
    get :show, :id => 1
    assert_response :success
  end

end
