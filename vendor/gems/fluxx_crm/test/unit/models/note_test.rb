require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  def setup
    @note = Note.make
  end
  
  test "truth" do
    assert true
  end
end