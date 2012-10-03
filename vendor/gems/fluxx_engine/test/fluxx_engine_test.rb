require 'test_helper'

class FluxxEngineTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, FluxxEngine
    m = Musician.make
  end
end
