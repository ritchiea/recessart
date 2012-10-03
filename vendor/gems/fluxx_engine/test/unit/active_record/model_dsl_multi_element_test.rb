require 'test_helper'

class ModelDslMultiElementTest < ActiveSupport::TestCase
  def setup
    add_multi_elements
  end
  
  test "test ability to add multi element to a class" do
    dsl_multi = ActiveRecord::ModelDslMultiElement.new Instrument
    dsl_multi.add_multi_elements
    test_instrument = Instrument.make
    assert test_instrument.respond_to?(:categories)
    assert test_instrument.respond_to?('choices_categories'.to_sym)
  end

  test "test ability to add single element to a class" do
    dsl_multi = ActiveRecord::ModelDslMultiElement.new Musician
    dsl_multi.add_multi_elements
    test_musician = Musician.make
    assert test_musician.respond_to?(:music_type_id)
    assert test_musician.respond_to?(:music_type)
  end

end