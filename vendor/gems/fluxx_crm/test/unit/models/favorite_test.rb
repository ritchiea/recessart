require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase
  def setup
    @favorite = Favorite.make
  end
  
  test "truth" do
    assert true
  end
end