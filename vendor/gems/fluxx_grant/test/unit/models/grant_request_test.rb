require 'test_helper'

class GrantRequestTest < ActiveSupport::TestCase
  def setup
    @req = GrantRequest.make
  end
  
  test "create a request and check initial state transition" do
    assert_equal 'new', @req.state
  end

  test "create a new request and try to reject- should be able to" do
    @req.reject
  end

  test "create a request and check the amount_requested filter" do
    r = Request.new :amount_requested => "$200,000"
    assert_equal 200000, r.amount_requested
  end
  
  test "create a request and check the amount_recommended filter" do
    r = Request.new :amount_recommended => "$200,000"
    assert_equal 200000, r.amount_recommended
  end
  
  test "create a request and check the old_amount_funded filter" do
    r = Request.new :amount_recommended => "$200,000"
    assert_equal 200000, r.amount_recommended.to_i
  end

  test "create a request and try to reject" do
    user = User.make
    Request.all_workflow_states.each do |cur_state|
      @req.state = cur_state
      @req.insta_fire_event :reject, user
      assert_equal 'rejected', @req.state
    end
  end

  test "create a request and try to unreject" do
    @req.state = 'rejected'
    @req.insta_fire_event :un_reject, User.make
    assert_equal 'new', @req.state
  end

  test "create a new request and recommend for funding" do
    @req.insta_fire_event :recommend_funding, User.make
    assert_equal 'funding_recommended', @req.state
  end

  test "create a new request and complete ierf" do
    @req.state = 'funding_recommended'
    @req.insta_fire_event :complete_ierf, User.make
    assert_equal 'pending_grant_team_approval', @req.state
  end

  test "create a sent_back_to_pa sentback request and complete ierf" do
    @req.state = 'sent_back_to_pa'
    @req.insta_fire_event :complete_ierf, User.make
    assert_equal 'pending_grant_team_approval', @req.state
  end

  test "create a request and grant_team approve" do
    @req.state = 'pending_grant_team_approval'
    @req.insta_fire_event :grant_team_approve, User.make
    assert_equal 'pending_po_approval', @req.state
  end

  test "create a request and grant_team approve then send back to PA" do
    @req.state = 'pending_grant_team_approval'
    @req.save
    assert_difference('WorkflowEvent.count') do
      @req.insta_fire_event :grant_team_approve, User.make
      @req.save
    end
    assert_equal 'pending_po_approval', @req.state
    @req.insta_fire_event :po_send_back, User.make
    @req.save
    assert_equal 'sent_back_to_pa', @req.state
    @req.insta_fire_event :complete_ierf, User.make
    @req.save
    assert_equal 'pending_po_approval', @req.state
  end

  test "create a request and po approve" do
    @req.state = 'pending_po_approval'
    @req.insta_fire_event :po_approve, User.make
    assert_equal 'pending_president_approval', @req.state
  end

  test "create a pd sent back request and po approve" do
    @req.state = 'sent_back_to_po'
    @req.insta_fire_event :po_approve, User.make
    assert_equal 'pending_president_approval', @req.state
  end

  test "send back by po" do
    @req.state = 'pending_po_approval'
    @req.insta_fire_event :po_send_back, User.make
    assert_equal 'sent_back_to_pa', @req.state
  end

  test "create a request and president approve" do
    @req.state = 'pending_president_approval'
    @req.insta_fire_event :president_approve, User.make
    assert_equal 'pending_grant_promotion', @req.state
  end

  test "send back by president" do
    @req.state = 'pending_president_approval'
    @req.insta_fire_event :president_send_back, User.make
    assert_equal 'sent_back_to_po', @req.state
  end

  test "request becomes a grant" do
    @req.state = 'pending_grant_promotion'
    @req.duration_in_months = 12
    @req.amount_recommended = 45000
    @req.insta_fire_event :become_grant, User.make
    assert_equal 'granted', @req.state
  end
  
  test "creating a request will result in an entry in the model deltas table" do
    max_realtime_id = RealtimeUpdate.maximum :id
    temp_req = nil
    assert_difference('Request.count') do
      temp_req = GrantRequest.make
    end
    after_max_realtime_id = RealtimeUpdate.maximum :id
    grant_request_rts = RealtimeUpdate.where(['id > ?', max_realtime_id]).where(:type_name => GrantRequest.name, :action => 'create').all
    assert_equal 1, grant_request_rts.size
    assert_equal temp_req.id, grant_request_rts.first.model_id
    model_delta = RealtimeUpdate.find :last
    assert_equal 'create', model_delta.action
  end
  
  test "updating a request will result in an entry in the model deltas table" do
    assert_difference('RealtimeUpdate.count') do
      result = @req.update_attributes :project_summary => 'howdy folks'
    end
    model_delta = RealtimeUpdate.find :last
    assert_equal 'update', model_delta.action
  end
  
  test "deleting a request will result in an entry in the model deltas table" do
    assert_difference('RealtimeUpdate.count') do
      @req.update_attributes :deleted_at => Time.now
    end
    model_delta = RealtimeUpdate.find :last
    assert_equal 'delete', model_delta.action
    assert_difference('RealtimeUpdate.count') do
      @req.destroy
    end
    model_delta = RealtimeUpdate.find :last
    assert_equal 'delete', model_delta.action
  end
  
  test 'create a blank request should include po' do
    assert @req.event_timeline.include?('pending_po_approval')
  end
  
  test 'end date should be the last of the month before duration months in the future from the start date' do
    @req.grant_begins_at = Time.parse '2010-03-01'
    
    assert_equal Time.utc(2011, 2, 28, 0, 0, 0), @req.grant_ends_at
  end
  
  test "create a grant and try to cancel" do
    @req.state = 'granted'
    @req.insta_fire_event :cancel_grant, User.make
    assert_equal 'canceled', @req.state
  end
  
  test "create program signatory roles, then remove program org, should get a null program signatory user and role" do
    request_with_program_org = GrantRequest.make :program_organization => Organization.make
    user = User.make
    request_with_program_org.grantee_org_owner = user
    request_with_program_org.save
    assert_equal user, request_with_program_org.grantee_org_owner
    request_with_program_org.program_organization = nil
    request_with_program_org.save
    assert !request_with_program_org.grantee_org_owner
  end
  
  test "create fiscal signatory roles, then remove fiscal org, should get a null fiscal signatory user and role" do
    request_with_fiscal_org = GrantRequest.make :fiscal_organization => Organization.make
    user = User.make
    request_with_fiscal_org.fiscal_org_owner = user
    request_with_fiscal_org.save
    assert_equal user, request_with_fiscal_org.fiscal_org_owner
    request_with_fiscal_org.fiscal_organization = nil
    request_with_fiscal_org.save
    assert !request_with_fiscal_org.fiscal_org_owner
  end
  
  test "test cascading deletes for request when request is deleted" do
    req_tran1 = RequestTransaction.make :request => @req
    req_tran2 = RequestTransaction.make :request => @req
    req_rep1 = RequestReport.make  :request => @req
    req_rep2 = RequestReport.make  :request => @req
    cur_user = User.make
    @req.safe_delete cur_user
    assert @req.reload.deleted_at
    assert req_tran1.reload.deleted_at
    assert req_tran2.reload.deleted_at
    assert req_rep1.reload.deleted_at
    assert req_rep2.reload.deleted_at
    
  end
  
  test "test cascading deletes for request when request is not deleted" do
    req_tran1 = RequestTransaction.make :request => @req
    req_tran2 = RequestTransaction.make :request => @req
    req_rep1 = RequestReport.make  :request => @req
    req_rep2 = RequestReport.make  :request => @req
    cur_user = User.make
    @req.update_attributes :amount_recommended => ((@req.amount_requested || 50) + 100)
    assert @req.reload.deleted_at.blank?
    assert req_tran1.reload.deleted_at.blank?
    assert req_tran2.reload.deleted_at.blank?
    assert req_rep1.reload.deleted_at.blank?
    assert req_rep2.reload.deleted_at.blank?
  end

  test "test amendments" do
    @req.update_attributes :state => 'granted'
    @req.update_attributes :amend => true, :amount_recommended => 10000, :duration_in_months => 20
    amend = @req.request_amendments.last
    assert_equal 20, amend.duration
    assert_equal 10000, amend.amount_recommended
    assert_equal false, amend.original
  end

  test "test amendment notes" do
    @req.update_attributes :state => 'granted', :amount_recommended => 1000, :duration_in_months => 20
    @req.update_attributes :amend => true, :amount_recommended => 2000, :duration_in_months => 10
    assert_equal @req.notes.last.note, "Amount amended from 1000 to 2000. Duration amended from 20 to 10."
  end

  test "test amendment notes with extra text" do
    @req.update_attributes :state => 'granted', :amount_recommended => 2000
    @req.update_attributes :amend => true, :amount_recommended => 3000, :amend_note => "Hell yeah!"
    assert_equal @req.notes.last.note, "Amount amended from 2000 to 3000. Hell yeah!"
  end

  test "test original entry in amendments" do
    @req.update_attributes :state => 'pending_grant_promotion'
    @req.update_attributes :state => "granted", :amount_recommended => 1500
    amend = @req.request_amendments.last
    assert_equal 1500, amend.amount_recommended
    assert amend.original
  end

  test "test funding source warning about charity check" do
    Organization.expects(:charity_check_enabled).returns(true)
    @req.state = 'funding_recommended'
    @req.insta_fire_event :complete_ierf, User.make
    @req.program_organization.expects(:c3_status_approved?).returns(false)
    assert_equal 'No c3 status', @req.funding_warnings.first
  end

  test "test funding source warning about duration over 12 months" do
    Organization.expects(:charity_check_enabled).returns(true)
    @req.state = 'funding_recommended'
    @req.duration_in_months = 15
    @req.insta_fire_event :complete_ierf, User.make
    @req.program_organization.expects(:c3_status_approved?).returns(true)
    assert_equal 'Duration is over 12 months', @req.funding_warnings.first
  end

  test "test funding source warning about expiration before estimated grant close date" do
    Organization.expects(:charity_check_enabled).returns(true)
    @req.state = 'funding_recommended'
    @req.duration_in_months = 15
    @req.insta_fire_event :complete_ierf, User.make
    @req.program_organization.expects(:c3_status_approved?).returns(true)
    @req.expects(:funding_sources_expired_before_close_date).returns("foo, bar")
    assert_equal 'Funding source(s) foo, bar expire before the estimated grant close date', @req.funding_warnings.last
  end

  test "test request funding sources are deleted after a request is canceled" do
    @req.request_funding_sources << [RequestFundingSource.make, RequestFundingSource.make]
    @req.update_attribute(:state, 'canceled')

    assert @req.reload.request_funding_sources.empty?
  end

  test "test request funding sources are deleted after a request is rejected" do
    @req.request_funding_sources << [RequestFundingSource.make, RequestFundingSource.make]
    @req.update_attribute(:state, 'rejected')

    assert @req.reload.request_funding_sources.empty?
  end
end
