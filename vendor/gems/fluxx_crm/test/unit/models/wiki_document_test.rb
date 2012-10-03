require 'test_helper'

class WikiDocumentTest < ActiveSupport::TestCase
  def setup
    @wiki_document = WikiDocument.make
  end

  test "truth" do
    assert true
  end
end