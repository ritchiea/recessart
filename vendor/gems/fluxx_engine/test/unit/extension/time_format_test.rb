require 'test_helper'

class TimeFormatTest < ActiveSupport::TestCase
  def setup
  end

  test "try various time formats" do
    [:msoft, :sql, :ampm_time, :mdy_time, :mdy, :full, :date_time_seconds, :date_time, :next_business_day, :previous_business_day].each do |format_sym|
      time_flavor = Time.now.send format_sym
      assert time_flavor
      assert String, time_flavor.class
    end
  end
  
  test "try skip weekends time format" do
    time_flavor = Time.now.skip_weekends 10
    assert time_flavor
    assert String, time_flavor.class
  end
  
  test "strip_zeros_from_date" do
    assert_equal strip_zeros_from_date('01/01/2011'), '1/1/2011'
    assert_equal strip_zeros_from_date('01/10/2011'), '1/10/2011'
    assert_equal strip_zeros_from_date('1/1/2011'), '1/1/2011'
    assert_equal strip_zeros_from_date('1/01/2011'), '1/1/2011'
    assert_equal strip_zeros_from_date('1/10/2011'), '1/10/2011'
    assert_equal strip_zeros_from_date('10/01/2011'), '10/1/2011'
    assert_equal strip_zeros_from_date('10/10/2011'), '10/10/2011'
    assert_equal strip_zeros_from_date('01/01/01'), '1/1/01'
    assert_equal strip_zeros_from_date('1/01/01'), '1/1/01'
    assert_equal strip_zeros_from_date('1/1/01'), '1/1/01'

    assert_equal strip_zeros_from_date('01-01-2011'), '1-1-2011'
    assert_equal strip_zeros_from_date('01-10-2011'), '1-10-2011'
    assert_equal strip_zeros_from_date('1-1-2011'), '1-1-2011'
    assert_equal strip_zeros_from_date('1-01-2011'), '1-1-2011'
    assert_equal strip_zeros_from_date('1-10-2011'), '1-10-2011'
    assert_equal strip_zeros_from_date('10-01-2011'), '10-1-2011'
    assert_equal strip_zeros_from_date('10-10-2011'), '10-10-2011'
    assert_equal strip_zeros_from_date('01-01-01'), '1-1-01'
    assert_equal strip_zeros_from_date('1-01-01'), '1-1-01'
    assert_equal strip_zeros_from_date('1-1-01'), '1-1-01'   
  end
end