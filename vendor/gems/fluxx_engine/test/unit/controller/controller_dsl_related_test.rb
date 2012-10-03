require 'test_helper'

class ControllerDslRelatedTest < ActiveSupport::TestCase
  def setup
    @dsl_related = ActionController::ControllerDslRelated.new Musician
  end

  test "test add_related ordering" do
    @dsl_related.add_related do |insta|
      insta.display_name = 'Instrument 1'
      insta.for_search do |model|
        Instrument.all
      end
      insta.display_template = 'template'
    end
    @dsl_related.add_related do |insta|
      insta.display_name = 'Instrument 2'
      insta.for_search do |model|
        Instrument.all
      end
      insta.display_template = 'template'
    end
    
    assert_equal 2, @dsl_related.relations.size
    assert_equal 'Instrument 1', @dsl_related.relations[0].display_name
    assert_equal 'Instrument 2', @dsl_related.relations[1].display_name
  end
  
  test "test calling load_related_data with a non-block" do
    musician = Musician.make
    5.times do
      instrument = Instrument.make
      musician.instruments << instrument
    end
    @dsl_related.add_related do |insta|
      insta.display_name = 'Instrument 1'
      insta.for_search do |model|
        Instrument.all
      end
      insta.display_template = 'template'
    end
   
   related = @dsl_related.load_related_data InstrumentsController.new, musician 
   musician.instruments.each_with_index do |instrument, i|
     assert_equal instrument, related.first[:formatted_data][i][:model]
   end
  end
end