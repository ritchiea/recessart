require 'test_helper'

class AlertTest < ActiveSupport::TestCase
  def alert_is_triggered_for_work_task(work_task_opts)
    work_task = WorkTask.make(work_task_opts)
    rtu = RealtimeUpdate.make(:type_name => WorkTask.name, :model_id => work_task.id)

    alert_is_triggered
  end

  def alert_is_triggered
    is_triggered = false
    Alert.with_triggered_alerts!{|triggered_alert, matching_rtus| is_triggered = true }
    is_triggered
  end

  def create_work_task_alert(alert_filter)
    alert_filter_as_json = alert_filter.inject([]) do |array, (k,v)|
      array << {"name" => "work_task[#{k}][]", "value" => v}
      array
    end.to_json

    Alert.create!(:name => "an alert", :filter => alert_filter_as_json)
  end

  def setup
    RealtimeUpdate.delete_all
  end

  test "alerts should have a unique name" do
    alert1 = Alert.make
    alert2 = Alert.make_unsaved(:name => alert1.name)
    alert2.valid?
    assert_equal "has already been taken", alert2.errors[:name].first
  end

  test "no alert is triggered if we don't have any alert" do
    assert_equal 0, Alert.count
    assert !alert_is_triggered
  end

  test "no alert is triggered if there are no rtus" do
    Alert.make
    assert !alert_is_triggered
  end

  test "no alert is triggered if the rtus have already been processed" do
    rtu = RealtimeUpdate.make
    Alert.make(:last_realtime_update_id => rtu.id)
    assert !alert_is_triggered
  end

  test "alert should coalesce rtus that point to the same model" do
    Alert.make
    user1 = User.make
    rtu1 = RealtimeUpdate.make(:type_name => User.name, :model_class => User.name, :model_id => user1.id)
    rtu2 = RealtimeUpdate.make(:type_name => User.name, :model_class => User.name, :model_id => user1.id)
    rtu3 = RealtimeUpdate.make(:type_name => User.name, :model_class => User.name, :model_id => user1.id)
    user2 = User.make
    rtu4 = RealtimeUpdate.make(:type_name => User.name, :model_class => User.name, :model_id => user2.id)
    rtu5 = RealtimeUpdate.make(:type_name => User.name, :model_class => User.name, :model_id => user2.id)
    rtu6 = RealtimeUpdate.make(:type_name => User.name, :model_class => User.name, :model_id => user2.id)

    filtered_models = []

    Alert.any_instance.stubs(:should_be_triggered_by_model?).returns(true)
    Alert.any_instance.stubs(:has_rtu_based_filtered_attrs?).returns(true)
    Alert.with_triggered_alerts!{|triggered_alert, matching_models| filtered_models = matching_models }
    assert_equal [user1, user2], filtered_models
  end

  test "alert is triggered if the overdue matcher matches the rtu" do
    create_work_task_alert(:name => "the name", :overdue_by_days => "8")
    assert alert_is_triggered_for_work_task(:name => "the name", :due_at => 10.days.ago)
  end

  test "alert is not triggered if the overdue_by_days matcher does not match the rtu" do
    create_work_task_alert(:name => "the name", :overdue_by_days => "11")
    assert !alert_is_triggered_for_work_task(:name => "the name", :due_at => 10.days.ago)
  end

  test "alert is not triggered if the equality matcher does not match the name" do
    create_work_task_alert(:name => "some name", :overdue_by_days => "8")
    assert !alert_is_triggered_for_work_task(:name => "the name", :due_at => 10.days.ago)
  end

  test "alert is triggered if the due_in_days matcher matches the rtu" do
    create_work_task_alert(:name => "the name", :due_in_days => "8")
    assert alert_is_triggered_for_work_task(:name => "the name", :due_at => 7.days.from_now)
  end

  test "alert is not triggered if the due_in_days matcher does not match the rtu" do
    create_work_task_alert(:name => "the name", :due_in_days => "11")
    assert !alert_is_triggered_for_work_task(:name => "the name", :due_at => 12.days.from_now)
  end

  test "rtus are not used to match overdue_by_days matchers" do
    create_work_task_alert(:overdue_by_days => "8")
    WorkTask.make(:due_at => 10.days.ago)
    RealtimeUpdate.delete_all

    assert alert_is_triggered
  end

  test "rtus are not used to match due_at matchers" do
    create_work_task_alert(:due_in_days => 8)
    WorkTask.make(:due_at => 7.days.from_now)
    RealtimeUpdate.delete_all

    assert alert_is_triggered
  end

  test "bla" do
    a = '[{"name":"work_task[report_type][]","value":"InterimBudget"},{"name":"work_task[hierarchies][]","value":"allocation_hierarchy"}]'
  end
end
