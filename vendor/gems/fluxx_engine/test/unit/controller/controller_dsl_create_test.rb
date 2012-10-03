require 'test_helper'

class ControllerDslCreateTest < ActiveSupport::TestCase
  def setup
  end

  test "check that we can load a new model" do
    @dsl_create = ActionController::ControllerDslCreate.new Musician
    musician = @dsl_create.load_new_model({})
    assert musician
    assert musician.is_a? Musician
  end

  test "check that we can load a model that's already loaded" do
    @dsl_create = ActionController::ControllerDslCreate.new Musician
    new_musician = Musician.new
    musician = @dsl_create.load_new_model({}, new_musician)
    assert_equal new_musician, musician
  end
  
  test "check that we can load a new model with params" do
    @dsl_create = ActionController::ControllerDslCreate.new Musician
    musician = @dsl_create.load_new_model({:musician => {:first_name => 'fred', :last_name => 'hoover'}})
    assert musician
    assert 'fred', musician.first_name
    assert 'hoover', musician.last_name
  end

  test "check that we can create a model" do
    @dsl_create = ActionController::ControllerDslCreate.new Musician
    musician = Musician.new(:first_name => 'John', :last_name => 'Smith')
    assert = @dsl_create.perform_create({}, musician)
    assert musician.errors.blank?
    assert musician.id
  end

  test "check that we can create a model with a fluxx user" do
    @dsl_create = ActionController::ControllerDslCreate.new Instrument
    fluxx_user = Musician.make
    instrument = Instrument.new
    assert = @dsl_create.perform_create({}, instrument, fluxx_user)
    assert instrument.errors.blank?
    assert !fluxx_user.id.blank?
    assert fluxx_user.id, instrument.created_by_id
    assert fluxx_user.id, instrument.updated_by_id
  end
  
  test "check that we can execute the post process autocomplete block" do
    @dsl_create = ActionController::ControllerDslCreate.new Instrument
    fluxx_user = Musician.make
    new_instrument = Instrument.new
    test_params = {:instrument => {:name => 'clarinet'}}
    block_invoked = false
    @dsl_create.post_save_call = (lambda do |fluxx_current_user, model, params|
      assert_equal fluxx_user, fluxx_current_user
      assert_equal test_params, params
      block_invoked = true
    end)
    
    instrument = @dsl_create.perform_create(test_params, new_instrument, fluxx_user)
    assert block_invoked
  end
  
end