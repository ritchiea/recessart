require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @doc = Document.make()
  end
  
  test "should create document" do
    assert_difference('Document.count') do
      post :create, :document => {:document => Sham.document}
    end
  end
  
  test "should destroy document" do
    assert_difference('Document.count', -1) do
      delete :destroy, :id => @doc.to_param
    end
  end
end
