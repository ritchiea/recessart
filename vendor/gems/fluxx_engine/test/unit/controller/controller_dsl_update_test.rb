require 'test_helper'

class ControllerDslUpdateTest < ActiveSupport::TestCase
  def setup
  end

  test "check that we can load an existing model" do
    @dsl_update = ActionController::ControllerDslUpdate.new Musician
    musician = Musician.make
    loaded_musician = @dsl_update.load_existing_model({:id => musician.id})
    assert musician
    assert_equal musician, loaded_musician
  end

  test "check that we can load a model that's already loaded" do
    @dsl_update = ActionController::ControllerDslUpdate.new Musician
    musician = Musician.make
    loaded_musician = @dsl_update.load_existing_model({}, musician)
    assert_equal musician, loaded_musician
  end
  
  test "check that we cannot load a deleted_at model" do
    @dsl_update = ActionController::ControllerDslUpdate.new Instrument
    instrument = Instrument.make
    instrument.update_attributes :deleted_at => Time.now
    assert !(@dsl_update.load_existing_model({:id => instrument.id}))
  end

  test "check that we can update a model with a fluxx user" do
    fluxx_user = Musician.make
    instrument = Instrument.make
    @dsl_update = ActionController::ControllerDslUpdate.new Instrument
    @dsl_update.populate_model({:instrument => {:name => 'trombone'}}, instrument, fluxx_user)
    @dsl_update.perform_update({:instrument => {:name => 'trombone'}}, instrument, fluxx_user)
    assert_equal 'trombone', instrument.reload.name
    assert fluxx_user.id, instrument.updated_by_id
  end
  
  test "check that we can execute the post process autocomplete block" do
    fluxx_user = Musician.make
    new_instrument = Instrument.make
    @dsl_update = ActionController::ControllerDslUpdate.new Instrument
    test_params = {:instrument => {:name => 'clarinet'}}
    block_invoked = false
    @dsl_update.post_save_call = (lambda do |fluxx_current_user, model, params|
      assert_equal fluxx_user, fluxx_current_user
      assert_equal test_params, params
      block_invoked = true
    end)
    
    instrument = @dsl_update.perform_update(test_params, new_instrument, fluxx_user)
    assert block_invoked
  end
  
end