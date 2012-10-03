require 'test_helper'

class InstrumentTest < ActiveSupport::TestCase
  def setup
    @instrument = Instrument.make
  end
  
  test "test Instrument search" do
    list = Instrument.model_search ''
  end
  
  test "test instrument search with matching attribute is found" do
    list = Instrument.model_search '', {:instrument => {'name' => @instrument.name}}
    assert_equal @instrument.id, list.first
  end

  test "test instrument search with non matching attribute is not found" do
    list = Instrument.model_search '', {:instrument => {'name' => "#{@instrument.name}_this_cant_be_found"}}
    assert list.empty?
  end

  test "test instrument search by ID for some records" do
    list = Instrument.model_search '', {:instrument => {'name' => "#{@instrument.name}_this_cant_be_found"}}
    assert list.empty?
  end

  test "test instrument search" do
    instruments = ((1..10).map { Instrument.make }) + [@instrument]
    list = Instrument.model_search '', {:instrument => {'id' => instruments.map(&:id)}}
    assert_equal instruments.map(&:id).sort, list.sort
  end

  test "test locking without sphinx" do
    user = Instrument.make
    @instrument.add_lock user
    @instrument.remove_lock user
  end
  
  test "test that an audit record is created upon save" do
    assert_difference('Audit.count') do
      Instrument.make
    end
  end
end