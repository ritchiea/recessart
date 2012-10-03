require 'test_helper'

class RequestReportTest < ActiveSupport::TestCase
  def setup
    @rep = RequestReport.make
  end
  
  test "create a report and check initial state transition" do
    assert_equal 'new', @rep.state
  end

  test "take a report and receive the report" do
    @rep.insta_fire_event :receive_report, User.make
    assert_equal 'report_received', @rep.state
  end

  
  test "take a report and submit the report" do
    @rep.state = 'report_received'
    @rep.save
    @rep.insta_fire_event :submit_report, User.make
    assert_equal 'pending_lead_approval', @rep.state
  end

  test "submit a sent-back report" do
    @rep.state = 'sent_back_to_pa'
    @rep.save
    @rep.insta_fire_event :submit_report, User.make
    assert_equal 'pending_lead_approval', @rep.state
  end
  
  test "take a report pending lead approval and submit the report" do
    @rep.state = 'pending_lead_approval'
    @rep.save
    @rep.insta_fire_event :lead_approve, User.make
    assert_equal 'pending_grant_team_approval', @rep.state
  end

  test "approve a sent-back to lead report" do
    @rep.state = 'sent_back_to_lead'
    @rep.save
    @rep.insta_fire_event :lead_approve, User.make
    assert_equal 'pending_grant_team_approval', @rep.state
  end
  
  test "take a report pending grant team approval for a non-ER request and submit the report" do
    @rep.state = 'pending_grant_team_approval'
    @rep.save
    @rep.insta_fire_event :grant_team_approve, User.make
    assert_equal 'approved', @rep.state
  end

  test "take a report pending grant team approval for an ER request and submit the report" do
    er_org = Organization.make :tax_class => bp_attrs[:er_tax_status]
    assert er_org.is_er?
    er_request = GrantRequest.make :state => 'pending_grant_promotion', :program_organization => er_org, :granted => 1, :state => :granted
    assert er_request.is_er?
    er_rep = RequestReport.make :request => er_request, :report_type => RequestReport.final_budget_type_name
    assert_equal er_request, er_rep.request
    assert er_rep.is_grant_er?
    er_rep.state = 'pending_grant_team_approval'
    er_rep.save
    er_rep.insta_fire_event :grant_team_approve, User.make
    assert_equal 'pending_finance_approval', er_rep.state
  end

  test "take a report pending grant team approval for an ER request and submit an interim report will not get to the finance team" do
    er_org = Organization.make :tax_class => bp_attrs[:er_tax_status]
    assert er_org.is_er?
    er_request = GrantRequest.make :state => 'pending_grant_promotion', :program_organization => er_org, :granted => 1, :state => :granted
    assert er_request.is_er?
    er_rep = RequestReport.make :request => er_request, :report_type => RequestReport.interim_budget_type_name
    assert_equal er_request, er_rep.request
    assert er_rep.is_grant_er?
    er_rep.state = 'pending_grant_team_approval'
    er_rep.save
    er_rep.insta_fire_event :grant_team_approve, User.make
    assert_equal RequestReport.approved_state, er_rep.state
  end

  test "approve a sent-back to grant team report for an ER request" do
    @rep.state = 'sent_back_to_grant_team'
    @rep.save
    @rep.insta_fire_event :grant_team_approve, User.make
    assert_equal RequestReport.approved_state, @rep.state
  end
  
  test "create a request report and approve, make sure the approved_at time is set" do
    rep = RequestReport.make :state => 'pending_grant_team_approval'
    assert_nil rep.approved_at
    rep.insta_fire_event :grant_team_approve, User.make
    assert rep.approved_at
  end
  
end
