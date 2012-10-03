require 'test_helper'

class <%= model_class_name %>Test < ActiveSupport::TestCase
  def setup
    @<%= model_class_singular_table_name %> = <%= model_class_name %>.make
  end
  
  test "truth" do
    assert true
  end
end