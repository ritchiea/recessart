require 'test_helper'

class ControllerDslDeleteTest < ActiveSupport::TestCase
  def setup
  end

  test "check that we can load a new model" do
    @dsl_delete = ActionController::ControllerDslDelete.new Musician
    musician = Musician.make
    musician = @dsl_delete.load_existing_model({:id => musician.id})
    assert musician
    assert musician.is_a? Musician
  end

  test "check that we can load a model that's already loaded" do
    new_musician = Musician.new
    @dsl_delete = ActionController::ControllerDslDelete.new Musician
    musician = @dsl_delete.load_existing_model({}, new_musician)
    assert_equal new_musician, musician
  end
  
  test "check that we can really delete a model" do
    @dsl_delete = ActionController::ControllerDslDelete.new Musician
    musician = Musician.make
    assert_difference('Musician.count', -1) do
      @dsl_delete.perform_delete({}, musician)
    end
  end

  test "check that we can set deleted_at on a model" do
    @dsl_delete = ActionController::ControllerDslDelete.new Instrument
    instrument = Instrument.make
    assert_difference('Instrument.count', 0) do
      instrument = @dsl_delete.perform_delete({}, instrument)
    end
    assert instrument.deleted_at
  end
  
  test "check that we can delete a model with a fluxx user" do
    fluxx_user = Musician.make
    @dsl_delete = ActionController::ControllerDslDelete.new Instrument
    instrument = Instrument.make
    assert_difference('Instrument.count', 0) do
      instrument = @dsl_delete.perform_delete({}, instrument)
    end
    assert instrument.deleted_at
    assert fluxx_user.id, instrument.updated_by_id
  end
  
end
