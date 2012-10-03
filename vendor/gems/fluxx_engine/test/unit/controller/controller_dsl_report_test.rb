require 'test_helper'

class ControllerDslReportTest < ActiveSupport::TestCase
  def setup
    @instrument_report_provider = ActionController::ControllerDslReport.new InstrumentsController, Instrument
    # @instrument_report_provider.report_name_path = 'instruments'
  end

  test "check that we can load report classes" do
    instrument_report_classes = @instrument_report_provider.load_report_classes
    assert_equal 2, instrument_report_classes.size
    assert instrument_report_classes.map(&:name).include?("TotalInstrumentsReport")
  end
  
  test "check that we can load reports and assign ids" do
    instrument_reports = @instrument_report_provider.instantiate_reports
    assert_equal instrument_reports.first.class.name.hash, instrument_reports.first.report_id
  end
  
  test "check that ordering works for reports" do
    instrument_reports = @instrument_report_provider.instantiate_reports
    assert_equal TotalInstrumentsReport, instrument_reports.first.class
    assert_equal AverageInstrumentsReport, instrument_reports.second.class
  end
  
end
