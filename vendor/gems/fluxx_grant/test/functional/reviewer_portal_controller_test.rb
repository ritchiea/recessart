require 'test_helper'

class ReviewerPortalControllerTest < ActionController::TestCase

  def setup
    user_profile = UserProfile.where(:name => 'Reviewer').first || UserProfile.make(:name => 'Reviewer')
    @user1 = User.make :user_profile => user_profile
    login_as @user1
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end

end
