require 'test_helper'

class ModelDocumentsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @model_doc = ModelDocument.make(:documentable => User.make)
  end
  
  test "should create model document" do
    org = Organization.make
    assert_difference('ModelDocument.count') do
      post :create, :model_document => {:document => Sham.document, :documentable_id => org.id, :documentable_type => org.class.name, :model_document_actual_filename => 'some file name'}
    end
  end
  
  test "should destroy model_document" do
    assert_difference('ModelDocument.count', -1) do
      delete :destroy, :id => @model_doc.to_param
    end
  end
end
