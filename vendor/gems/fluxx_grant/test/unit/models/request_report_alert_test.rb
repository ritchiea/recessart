require 'test_helper'

class RequestReportAlertTest < ActiveSupport::TestCase
  def alert_is_triggered_for_request_report(request_report_opts)
    request_report = RequestReport.make(request_report_opts)
    rtu = RealtimeUpdate.make(:type_name => RequestReport.name, :model_id => request_report.id)

    alert_is_triggered
  end

  def alert_is_triggered
    is_triggered = false
    Alert.with_triggered_alerts!{|triggered_alert, matching_rtus| is_triggered = true }
    is_triggered
  end

  def create_alert(alert_opts)
    RequestReportAlert.create!(:name => alert_opts.delete(:name) || "an alert").tap do |alert|
      alert.update_attributes(alert_opts)
    end
  end

  def setup
    RealtimeUpdate.delete_all
  end

  test "alert is triggered if the overdue matcher matches the rtu" do
    create_alert(:state => "approved", :overdue_by_days => "8")
    assert alert_is_triggered_for_request_report(:state => "approved", :due_at => 10.days.ago)
  end

  test "alert is not triggered if the overdue_by_days matcher does not match the rtu" do
    create_alert(:state => "approved", :overdue_by_days => "11")
    assert !alert_is_triggered_for_request_report(:state => "approved", :due_at => 10.days.ago)
  end

  test "alert is not triggered if the equality matcher does not match the state" do
    create_alert(:state => "new", :overdue_by_days => "8")
    assert !alert_is_triggered_for_request_report(:state => "approved", :due_at => 10.days.ago)
  end

  test "alert is triggered if the due_within_days matcher matches the rtu" do
    create_alert(:state => "approved", :due_within_days => "8")
    assert alert_is_triggered_for_request_report(:state => "approved", :due_at => 7.days.from_now)
  end

  test "alert is not triggered if the due_within_days matcher does not match the rtu" do
    create_alert(:state => "approved", :due_within_days => "11")
    assert !alert_is_triggered_for_request_report(:state => "approved", :due_at => 12.days.from_now)
  end

  test "rtus are not used to match overdue_by_days matchers" do
    create_alert(:overdue_by_days => "8")
    RequestReport.make(:due_at => 10.days.ago)
    RealtimeUpdate.delete_all

    assert alert_is_triggered
  end

  test "rtus are not used to match due_at matchers" do
    create_alert(:due_within_days => "8")
    RequestReport.make(:due_at => 7.days.from_now)
    RealtimeUpdate.delete_all

    assert alert_is_triggered
  end

  test "params from the model search filter can be used to create an alert" do
    params = HashWithIndifferentAccess.new("type"=>"RequestReportAlert",
                                           "request_report"=>{"due_within_days"=>"14",
                                                              "overdue_by_days"=>"15",
                                                              "sort_order"=>"desc",
                                                              "report_type"=>["InterimBudget"],
                                                              "lead_user_ids"=>["383"],
                                                              "request_hierarchy"=>["3-8--"],
                                                              "favorite_user_ids"=>"",
                                                              "sort_attribute"=>"due_at",
                                                              "state"=>["report_received"],
                                                              "hierarchies"=>["request_hierarchy"]})

    alert = Alert.new_from_params(params)
    assert_equal ["report_received"], alert.state
    assert_equal ["14"], alert.due_within_days
    assert_equal ["15"], alert.overdue_by_days
    assert_equal ["InterimBudget"], alert.report_type
    assert_equal ["383"], alert.lead_user_ids
    assert_equal ["3"], alert.program_id
  end

  test "empty params can create an alert too" do
    params = HashWithIndifferentAccess.new("type"=>"RequestReportAlert")

    alert = Alert.new_from_params(params)
    assert_equal nil, alert.state
    assert_equal nil, alert.due_within_days
    assert_equal nil, alert.overdue_by_days
    assert_equal nil, alert.report_type
    assert_equal nil, alert.lead_user_ids
    assert_equal nil, alert.program_id
  end
end
