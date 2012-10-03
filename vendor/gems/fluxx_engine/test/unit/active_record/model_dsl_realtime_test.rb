require 'test_helper'

class ModelDslRealtimeTest < ActiveSupport::TestCase
  def setup
    @dsl_realtime = ActiveRecord::ModelDslRealtime.new Musician
  end

  test "check that we create a realtime update record when we create a new model" do
    assert_difference 'RealtimeUpdate.count' do
      @musician = Musician.make
    end
    
    rt = RealtimeUpdate.find :last
    assert_equal 'create', rt.action
    assert_equal @musician.id, rt.model_id
    assert_equal @musician.class.name, rt.model_class
  end

  test "check that we create a realtime update record when we update model" do
    @musician = Musician.make
    assert_difference 'RealtimeUpdate.count' do
      @musician.update_attributes :first_name => 'fiddle-dee'
    end
    
    rt = RealtimeUpdate.find :last
    assert_equal 'update', rt.action
    assert_equal @musician.id, rt.model_id
    assert_equal @musician.class.name, rt.model_class
  end

  test "check that we create a realtime update record when we delete a model" do
    @musician = Musician.make
    assert_difference 'RealtimeUpdate.count' do
      @musician.safe_delete nil
    end
    
    rt = RealtimeUpdate.find :last
    assert_equal 'delete', rt.action
    assert_equal @musician.id, rt.model_id
    assert_equal @musician.class.name, rt.model_class
  end

  test "check after realtime callbacks" do
    musician = Musician.make
    instrument = Instrument.make
    assert_difference 'RealtimeUpdate.count', 3 do
       MusicianInstrument.make :musician => musician, :instrument => instrument
    end
    
    rt = RealtimeUpdate.find :last
    assert_equal 'update', rt.action
    assert_equal instrument.id, rt.model_id
    assert_equal instrument.class.name, rt.model_class
  end
end