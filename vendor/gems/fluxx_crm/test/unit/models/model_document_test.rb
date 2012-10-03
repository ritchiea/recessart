require 'test_helper'

class ModelDocumentTest < ActiveSupport::TestCase
  def setup
    @model_document = ModelDocument.make(:documentable => User.make)
  end
  
  test "truth" do
    assert true
  end
end