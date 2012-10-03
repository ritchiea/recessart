require 'test_helper'

class InflectionsTest < ActiveSupport::TestCase
  def setup
  end

  test "try dehumanize" do
    assert_equal "my_fun_animal", "My fun animal".dehumanize
  end

  test "try de_json" do
    sample_array = [1, 2, 3, "fred"]
    sample_array_json = sample_array.to_json
    assert_equal sample_array, sample_array_json.de_json
  end

  test "try is_numeric" do
    assert "2343".is_numeric?
    assert !"asdf2343".is_numeric?
  end
end