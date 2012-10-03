require 'test_helper'

class ModelDslUtcTest < ActiveSupport::TestCase
  def setup
    @dsl_utc = ActiveRecord::ModelDslUtc.new(Musician)
    @dsl_utc.time_attributes = [:date_of_birth]
    @dsl_utc.add_utc_time_attributes
  end

  test "check that we get a UTC time" do
    musician = Musician.make :date_of_birth => nil
    musician.date_of_birth = '02-1-2008'
    assert musician.date_of_birth
    assert_equal Time, musician.date_of_birth.class
    assert musician.date_of_birth.utc?
  end

  test "check that we get a time with minutes/seconds chopped off" do
    musician = Musician.make :date_of_birth => nil
    musician.date_of_birth = '02-1-2008 12:26'
    assert musician.date_of_birth
    assert_equal 1, musician.date_of_birth.month #remember that months start at 0 not 1
    assert_equal 2, musician.date_of_birth.day
    assert_equal 2008, musician.date_of_birth.year
    assert_equal 0, musician.date_of_birth.hour
    assert_equal 0, musician.date_of_birth.min
    assert_equal 0, musician.date_of_birth.sec
  end

  test "check that we get an error for an invalid time" do
    musician = Musician.make :date_of_birth => nil
    musician.date_of_birth = '12-99-2008'
    assert !musician.date_of_birth
    assert musician.instance_variable_get :@utc_time_validate_errors
  end
end