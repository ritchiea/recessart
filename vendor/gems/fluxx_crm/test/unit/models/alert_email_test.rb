require 'test_helper'

class AlertEmailTest < ActiveSupport::TestCase
  test "delivery of all alert emails" do
    alert = Alert.make_unsaved
    alert.subject =  "the subject for {{recipient.email}} on project '{{model.title}}'"
    alert.body = "the body for {{recipient.email}} on project '{{model.title}}'"
    alert.save!

    johndoe = User.make(:email => "johndoe@fakemailaddress.com")
    alert.alert_recipients.create!(:user_id => johndoe.id)

    janedoe = User.make(:email => "janedoe@fakemailaddress.com")
    project = Project.make(:title => "conquer the world", :created_by_id => janedoe.id)
    alert.alert_recipients.create!(:rtu_model_user_method => :creator)

    rtu = RealtimeUpdate.make(:type_name => Project.name, :model_id => project.id)
    Alert.attr_recipient_role(:creator, :recipient_finder => lambda{|model| model.created_by})
    RealtimeUpdate.where(:type_name => 'Musician').each(&:destroy)
    AlertEmail.enqueue(:alert, :alert => alert, :model => rtu.model)
    AlertEmail.deliver_all

    assert_equal 2, ActionMailer::Base.deliveries.size
    assert_equal ["johndoe@fakemailaddress.com", "janedoe@fakemailaddress.com"], ActionMailer::Base.deliveries.map{|e| e["to"].value}
    assert_equal "the subject for johndoe@fakemailaddress.com on project 'conquer the world'", ActionMailer::Base.deliveries.first.subject
    assert_equal "the body for johndoe@fakemailaddress.com on project 'conquer the world'", ActionMailer::Base.deliveries.first.body.to_s
    assert_equal "the subject for janedoe@fakemailaddress.com on project 'conquer the world'", ActionMailer::Base.deliveries.last.subject
    assert_equal "the body for janedoe@fakemailaddress.com on project 'conquer the world'", ActionMailer::Base.deliveries.last.body.to_s
  end

  test "send_at column is set to a fixed period of time since the last email with the same alert/model pair" do
    model = Project.make
    alert = Alert.make
    other_model = Project.make
    other_alert = Alert.make

    sent_matching_email = AlertEmail.create!(:alert => alert, :model => model, :delivered => true, :send_at => 6.days.ago)
    last_sent_matching_email = AlertEmail.create!(:alert => alert, :model => model, :delivered => true, :send_at => 5.days.ago)
    sent_email_that_does_not_match_the_model = AlertEmail.create!(:alert => alert, :model => other_model, :delivered => true, :send_at => 4.days.ago)
    sent_email_that_does_not_match_the_alert = AlertEmail.create!(:alert => other_alert, :model => model, :delivered => true, :send_at => 3.days.ago)

    new_alert_email = AlertEmail.enqueue(:alert, :alert => alert, :model => model)
    AlertEmail.stubs(:minimum_time_between_emails).returns(1.day)

    assert new_alert_email.send_at == (last_sent_matching_email.send_at + 1.day)
  end

  test "don't enqueue a new email if there's already an unsent email for the same alert/model pair" do
    model = Project.make
    alert = Alert.make

    unsent_alert_email = AlertEmail.enqueue(:alert, :alert => alert, :model => model)
    new_alert_email = AlertEmail.enqueue(:alert, :alert => alert, :model => model)

    assert_equal [unsent_alert_email], AlertEmail.all
  end

  test "enqueue a new email if there's already a sent email for the same alert/model pair" do
    model = Project.make
    alert = Alert.make

    sent_alert_email = AlertEmail.enqueue(:alert, :alert => alert, :model => model)
    sent_alert_email.update_attribute(:delivered, true)
    new_alert_email = AlertEmail.enqueue(:alert, :alert => alert, :model => model)

    assert_equal [sent_alert_email, new_alert_email], AlertEmail.all
  end

  test "time based alerts should not be sent more than once for each alert/model pair" do
    model1 = Project.make
    model2 = Project.make
    time_based_alert = Alert.make
    time_based_alert.stubs(:has_time_based_filtered_attrs?).returns(true)

    sent_alert_email = AlertEmail.enqueue(:alert, :alert => time_based_alert, :model => model1)
    sent_alert_email.update_attribute(:delivered, true)
    new_alert_email_for_model1 = AlertEmail.enqueue(:alert, :alert => time_based_alert, :model => model1)
    new_alert_email_for_model2 = AlertEmail.enqueue(:alert, :alert => time_based_alert, :model => model2)

    assert_equal [sent_alert_email, new_alert_email_for_model2], AlertEmail.all
  end

  test "only send undelivered emails that have send_at <= today" do
    model = Project.make
    alert1 = Alert.make
    alert2 = Alert.make

    unsent_email_with_send_at_in_past = AlertEmail.create!(:alert => alert1, :model => model, :delivered => false)
    unsent_email_with_send_at_in_past.update_attribute(:send_at, 1.day.ago)
    unsent_email_with_send_at_in_future = AlertEmail.create!(:alert => alert2, :model => model, :delivered => false)
    unsent_email_with_send_at_in_future.update_attribute(:send_at, 1.day.from_now)

    AlertEmail.deliver_all

    assert unsent_email_with_send_at_in_past.reload.delivered
    assert !unsent_email_with_send_at_in_future.reload.delivered
  end
end

