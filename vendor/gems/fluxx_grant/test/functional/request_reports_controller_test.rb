require 'test_helper'

class RequestReportsControllerTest < ActionController::TestCase

  def setup
    @org = Organization.make
    @program = Program.make
    @request1 = GrantRequest.make :program => @program, :program_organization => @org, :state => :granted, :granted => 1
    @file_fixture = fixture_file_upload('/files/file.txt', 'text/html')
    @request_final_report = RequestReport.make :request => @request1, :report_type => 'FinalBudget'
    @user1 = User.make
    login_as @user1
  end

  def check_models_are_updated
    assert_difference('WorkflowEvent.count') do
      yield
    end
  end
  
  def check_models_are_not_updated
    assert_difference('WorkflowEvent.count', 0) do
      yield
    end
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_reports)
  end
  
  test "should get index with due_within_days" do
    get :index, :due_within_days => 7
    assert_response :success
    assert_not_nil assigns(:request_reports)
  end
  
  test "should get index with overdue_by_days" do
    get :index, :overdue_by_days => 7
    assert_response :success
    assert_not_nil assigns(:request_reports)
  end
  
  test "should get index with grant_program_ids" do
    get :index, :grant_program_ids => [@program.id]
    assert_response :success
    assert_not_nil assigns(:request_reports)
  end

  test "should show request_report" do
    get :show, :id => @request_final_report.to_param
    assert_response :success
  end

  test "should get edit" do
    @request_eval_report = RequestReport.make :request => @request1, :report_type => 'Eval'
    get :edit, :id => @request_eval_report.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @request_eval_report = RequestReport.make :request => @request1, :report_type => 'Eval'
    @request_eval_report.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @request_eval_report.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @request_eval_report = RequestReport.make :request => @request1, :report_type => 'Eval'
    @request_eval_report.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @request_eval_report.to_param, :request_report => {}
    assert assigns(:not_editable)
  end

  test "should update request_eval_report" do
    @request_eval_report = RequestReport.make :request => @request1, :report_type => 'Eval'
    put :update, :id => @request_eval_report.to_param, :request_report => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_report_path(assigns(:request_report))}$/
  end

  test "should destroy request_report" do
    delete :destroy, :id => @request_final_report.id
    assert_not_nil @request_final_report.reload().deleted_at 
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_report_path(@request_final_report)}$/
  end
  
  test "try to have pa approve a report" do
    @program = @request1.program
    request_report1 = RequestReport.make :request => @request1, :report_type => RequestReport.interim_budget_type_name, :state => RequestReport.report_received_state
    
    login_as_user_with_role Program.program_associate_role_name
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.submit_report_event}
    
    assert_equal 'pending_lead_approval', request_report1.reload.state
    assert flash[:info]
  end
  
  test "try to have pa approve a sent-back report" do
    @program = @request1.program
    request_report1 = RequestReport.make :request => @request1, :report_type => RequestReport.interim_budget_type_name, :state => 'sent_back_to_pa'
    
    login_as_user_with_role Program.program_associate_role_name, @program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.submit_report_event}
    assert_equal 'pending_lead_approval', request_report1.reload.state
    assert flash[:info]
  end

  test "try to have lead approve a report" do
    @program = @request1.program
    request_report1 = RequestReport.make :request => @request1, :report_type => RequestReport.interim_budget_type_name, :state => 'pending_lead_approval'
    login_as_user_with_role Program.program_officer_role_name, @program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.lead_approve_event}
    assert_equal 'pending_grant_team_approval', request_report1.reload.state
    assert flash[:info]
  end

  test "try to have lead approve a sent-back report" do
    @program = @request1.program
    request_report1 = RequestReport.make :request => @request1, :report_type => RequestReport.interim_budget_type_name, :state => 'sent_back_to_lead'
    login_as_user_with_role Program.program_officer_role_name, @program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.lead_approve_event}
    assert_equal 'pending_grant_team_approval', request_report1.reload.state
    assert flash[:info]
  end
  
  test "try to have lead send back a pending report" do
    @program = @request1.program
    request_report1 = RequestReport.make :request => @request1, :report_type => RequestReport.interim_budget_type_name, :state => 'pending_lead_approval'
    login_as_user_with_role Program.program_officer_role_name, @program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.lead_send_back_event}
    assert_equal 'sent_back_to_pa', request_report1.reload.state
    assert flash[:info]
  end

  test "try to have grant team approve a report" do
    @program = @request1.program
    request_report1 = RequestReport.make :request => @request1, :report_type => RequestReport.interim_budget_type_name, :state => 'pending_grant_team_approval'
    assert @org.tax_class
    assert @request1.has_tax_class?
    assert_equal @request1, request_report1.request
    assert request_report1.has_tax_class?
    login_as_user_with_role Program.grants_administrator_role_name, @program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.grant_team_approve_event}
    assert_equal 'approved', request_report1.reload.state
    assert flash[:info]
  end

  test "try to have grant team approve a sent-back report" do
    @program = @request1.program
    request_report1 = RequestReport.make :request => @request1, :report_type => RequestReport.interim_budget_type_name, :state => 'sent_back_to_grant_team'
    login_as_user_with_role Program.grants_administrator_role_name, @program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.grant_team_approve_event}
    assert_equal 'approved', request_report1.reload.state
    assert flash[:info]
  end
  
  test "try to have grant team send back a pending report" do
    @program = @request1.program
    request_report1 = RequestReport.make :request => @request1, :report_type => RequestReport.interim_budget_type_name, :state => 'pending_grant_team_approval'
    login_as_user_with_role Program.grants_administrator_role_name, @program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.grant_team_send_back_event}
    assert_equal 'sent_back_to_lead', request_report1.reload.state
    assert flash[:info]
  end
  
  test "try to have grant team approve an ER report" do
    create_er_grant
    @program = @er_request.program
    request_report1 = RequestReport.make :request => @er_request, :report_type => RequestReport.interim_budget_type_name, :state => 'pending_grant_team_approval'
    login_as_user_with_role Program.grants_administrator_role_name, @program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.grant_team_approve_event}
    assert_equal 'approved', request_report1.reload.state
    assert flash[:info]
  end
  
  test "try to have finance team send back a pending report" do
    create_er_grant
    @program = @er_request.program
    request_report1 = RequestReport.make :request => @er_request, :report_type => RequestReport.interim_budget_type_name, :state => 'pending_finance_approval'
    login_as_user_with_role Program.finance_administrator_role_name, @program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.finance_send_back_event}
    assert_equal 'sent_back_to_grant_team', request_report1.reload.state
    assert flash[:info]
  end
  
  test "try to have finance team approve an ER report" do
    create_er_grant
    @program = @er_request.program
    request_report1 = RequestReport.make :request => @er_request, :report_type => RequestReport.interim_budget_type_name, :state => 'pending_finance_approval'
    login_as_user_with_role Program.finance_administrator_role_name, @program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.finance_approve_event}
    assert_equal 'approved', request_report1.reload.state
    assert flash[:info]
  end
  
  test "Create a rollup-program, assign the president that role and try to approve a program in that rollup" do
    create_er_grant
    @program = @er_request.program
    rollup_program = Program.make :rollup => true
    @program.parent_program = rollup_program
    @program.save
    request_report1 = RequestReport.make :request => @er_request, :report_type => RequestReport.interim_budget_type_name, :state => 'pending_finance_approval'
    login_as_user_with_role Program.finance_administrator_role_name, rollup_program
    check_models_are_updated{put :update, :id => request_report1.to_param, :event_action => RequestReport.finance_approve_event}
    assert_equal 'approved', request_report1.reload.state
    assert flash[:info]
  end
  
  def create_er_grant
    @er_org = Organization.make :tax_class => bp_attrs[:er_tax_status]
    assert @er_org.is_er?
    @er_request = GrantRequest.make :state => 'pending_grant_promotion', :program_organization => @er_org, :granted => 1, :state => :granted
    assert @er_request.is_er?
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:request_reports)
  end
end
