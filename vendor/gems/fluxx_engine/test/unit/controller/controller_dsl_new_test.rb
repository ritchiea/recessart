require 'test_helper'

class ControllerDslNewTest < ActiveSupport::TestCase
  def setup
  end

  test "check that we can load a new model" do
    @dsl_new = ActionController::ControllerDslNew.new Musician
    @musician = Musician.make
    new_musician = @dsl_new.load_new_model({})
    assert new_musician
    assert new_musician.is_a? Musician
  end
  
  test "check that we can load a model that's already loaded" do
    @dsl_new = ActionController::ControllerDslNew.new Musician
    @musician = Musician.make
    new_musician = @dsl_new.load_new_model({}, @musician)
    assert_equal @musician, new_musician
  end
end