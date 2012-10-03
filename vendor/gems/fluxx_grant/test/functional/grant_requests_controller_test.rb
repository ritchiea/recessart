require 'test_helper'

class GrantRequestsControllerTest < ActionController::TestCase
  
  def setup
    @org = Organization.make
    @program = Program.make
    @request1 = GrantRequest.make :program => @program, :program_organization => @org, :base_request_id => nil
    @user1 = User.make
    @user1.has_role! Program.program_officer_role_name, @program
    login_as @user1
  end
  
  # test "check on _allowed? methods" do
  #   @controller.session = @request.session
  #   @controller.load_request @request1.id
  #   assert @controller.reject_allowed?
  #   assert @controller.un_reject_allowed?
  #   assert @controller.recommend_funding_allowed?
  #   assert @controller.po_approve_allowed?
  #   assert @controller.po_send_back_allowed?
  #   assert !@controller.pd_approve_allowed?
  #   assert !@controller.pd_send_back_allowed?
  #   assert !@controller.svp_approve_allowed?
  #   assert !@controller.svp_send_back_allowed?
  #   assert !@controller.president_approve_allowed?
  #   assert !@controller.president_send_back_allowed?
  #   assert !@controller.become_grant_allowed?
  # end

  test "try to reject a request" do
     [(GrantRequest.all_workflow_states + GrantRequest.all_sent_back_states).first].each do |cur_state|
      @controller = GrantRequestsController.new
      Program.request_roles.each do |role_name|
        @request1.state = cur_state.to_s
        @request1.save
        login_as_user_with_role role_name
        check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'reject'}
        assert_equal 'rejected', @request1.reload().state
        assert flash[:info]
      end
    end
  end

  test "try to unreject a request" do
    [Program.request_roles.first].each do |role_name|
      @request1.state = 'rejected'
      @request1.save
      login_as_user_with_role role_name
      check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'un_reject'}
      assert_equal 'new', @request1.reload().state
      assert flash[:info]
    end
  end

  test "try to have PA recommend and approve a request" do
    login_as_user_with_role Program.program_associate_role_name
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'recommend_funding'}
    assert_equal 'funding_recommended', @request1.reload().state
    assert flash[:info]
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'complete_ierf'}
    assert_equal 'pending_grant_team_approval', @request1.reload().state
    assert flash[:info]
  end

  test "try to have PA complete a sent back request" do
    login_as_user_with_role Program.program_associate_role_name
    @request1.state = 'sent_back_to_pa'
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'complete_ierf'}
    assert_equal 'pending_grant_team_approval', @request1.reload().state
    assert flash[:info]
  end

  test "try to have GrantAdmin recommend and approve a request" do
    login_as_user_with_role Program.grants_administrator_role_name
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'recommend_funding'}
    assert_equal 'funding_recommended', @request1.reload().state
    assert flash[:info]
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'complete_ierf'}
    assert_equal 'pending_grant_team_approval', @request1.reload().state
    assert flash[:info]

    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'grant_team_send_back'}
    assert_equal 'sent_back_to_pa', @request1.reload().state
    assert flash[:info]
  end

  test "try to have GrantAdmin send back a request" do
    login_as_user_with_role Program.grants_administrator_role_name
    @request1.state = 'pending_grant_team_approval'
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'grant_team_send_back'}
    assert_equal 'sent_back_to_pa', @request1.reload().state
    assert flash[:info]
  end

  test "try to have GrantAdmin approve an already approved request and fail" do
    login_as_user_with_role Program.grants_administrator_role_name
    @request1.state = 'pending_po_approval'
    @request1.save
    check_models_are_not_updated{put :update, :id => @request1.to_param, :event_action => 'po_approve'}
    assert_equal 'pending_po_approval', @request1.reload().state
    assert flash[:error]
  end

  test "try to have PO recommend and approve a request" do
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'recommend_funding'}
    assert flash[:info]
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'complete_ierf'}
    assert_equal 'pending_grant_team_approval', @request1.reload().state
    assert flash[:info]

    @request1.state = 'pending_po_approval'
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'po_approve'}
    assert_equal 'pending_president_approval', @request1.reload().state
    assert flash[:info]
  end

  test "try to have PO send back a request" do
    @request1.state = 'pending_po_approval'
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'po_send_back'}
    assert_equal 'sent_back_to_pa', @request1.reload().state
    assert flash[:info]
  end

  test "try to have PO approve a sent back request" do
    @request1.state = 'sent_back_to_po'
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'po_approve'}
    assert_equal 'pending_president_approval', @request1.reload().state
    assert flash[:info]
  end

  test "try to have PO approve an already approved request and fail" do
    @request1.state = 'pending_president_approval'
    @request1.save
    check_models_are_not_updated{put :update, :id => @request1.to_param, :event_action => 'president_approve'}
    assert_equal 'pending_president_approval', @request1.reload().state
    assert flash[:error]
  end

  test "try to have president recommend and approve a request" do
    login_as_user_with_role Program.president_role_name
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'recommend_funding'}
    assert flash[:info]
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'complete_ierf'}
    assert_equal 'pending_grant_team_approval', @request1.reload().state
    assert flash[:info]
    @request1.state = 'pending_president_approval'
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'president_approve'}
    assert_equal 'pending_grant_promotion', @request1.reload().state
    assert flash[:info]
  end

  test "try to have president approve an already approved request and fail" do
    login_as_user_with_role Program.president_role_name
    @request1.state = 'pending_grant_promotion'
    @request1.save
    check_models_are_not_updated{put :update, :id => @request1.to_param, :event_action => 'president_approve'}
    assert_equal 'pending_grant_promotion', @request1.reload().state
    assert flash[:error]
  end

  test "try to have president send back a request" do
    login_as_user_with_role Program.president_role_name
    @request1.state = 'pending_president_approval'
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'president_send_back'}
    assert_equal 'sent_back_to_po', @request1.reload().state
    assert flash[:info]
  end

  test "Create a rollup-program, assign the president that role and try to approve a program in that rollup" do
    rollup_program = Program.make :rollup => true
    @program.parent_program = rollup_program
    @program.save

    login_as_user_with_role Program.president_role_name, rollup_program
    @request1.state = 'pending_president_approval'
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'president_approve'}
    assert_equal 'pending_grant_promotion', @request1.reload().state
    assert flash[:info]
  end

  test "try to have grant assistant approve a request" do
    login_as_user_with_role Program.grants_assistant_role_name
    @request1.state = 'pending_grant_promotion'
    @request1.duration_in_months = 12
    @request1.amount_recommended = 45000
    @request1.save
    check_models_are_not_updated{put :edit, :id => @request1.to_param, :approve_grant_details => true}
    assert_template :partial => '_approve_grant_details'
    er_request = assigns(:model)
  end

  test "try to have grant assistant approve an already approved request and make it closed" do
    login_as_user_with_role Program.grants_assistant_role_name
    @request1.state = 'closed'
    @request1.save
    check_models_are_not_updated{put :update, :id => @request1.to_param, :event_action => 'close_grant'}
    assert_equal 'closed', @request1.reload().state
  end

  test "try to have grant administrator approve a request" do
    login_as_user_with_role Program.grants_administrator_role_name
    @request1.state = 'pending_grant_promotion'
    @request1.duration_in_months = 12
    @request1.amount_recommended = 45000
    @request1.save
    check_models_are_not_updated{put :edit, :id => @request1.to_param, :approve_grant_details => true}
    assert_template :partial => '_approve_grant_details'
    er_request = assigns(:model)
  end

  test "try to have grant administrator approve an already approved request and make it closed" do
    login_as_user_with_role Program.grants_administrator_role_name
    @request1.state = 'granted'
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'close_grant'}
    assert_equal 'closed', @request1.reload().state
    assert flash[:info]
  end

  test "test that approve a greater than 1 year duration request for a non-profit to become a grant adds 3 request documents and creates the grant ID" do
    assert_nil @request1.grant_id
    login_as_user_with_role Program.grants_administrator_role_name
    @request1.state = 'pending_grant_promotion'
    @request1.duration_in_months = 18
    @request1.amount_recommended = 45000
    @request1.save
    assert_nil @request1.grant_id
    check_models_are_not_updated{put :edit, :id => @request1.to_param, :approve_grant_details => true}
    assert_template :partial => '_approve_grant_details'
    @request1 = assigns(:model)
    assert_equal 5, @request1.request_reports.size
    assert @request1.request_reports.first.report_type == RequestReport.interim_budget_type_name
    assert @request1.request_reports[1].report_type == RequestReport.interim_narrative_type_name
    assert @request1.request_reports[2].report_type == RequestReport.final_budget_type_name
    assert @request1.request_reports[3].report_type == RequestReport.final_narrative_type_name
    assert @request1.grant_id
  end

  test "test that approve a less than 1 year duration request for a new non-profit to become a grant for a new organization adds 3 request documents and creates the grant ID" do
    login_as_user_with_role Program.grants_administrator_role_name
    @request1.state = 'pending_grant_promotion'
    @request1.duration_in_months = 11
    @request1.amount_recommended = 45000
    @request1.save
    assert !@request1.grant_id
    check_models_are_not_updated{put :edit, :id => @request1.to_param, :approve_grant_details => true}
    assert_template :partial => '_approve_grant_details'
    @request1 = assigns(:model)
    assert_equal 5, @request1.request_reports.size
    assert @request1.request_reports.first.report_type == RequestReport.interim_budget_type_name
    assert @request1.request_reports[1].report_type == RequestReport.interim_narrative_type_name
    assert @request1.request_reports[2].report_type == RequestReport.final_budget_type_name
    assert @request1.request_reports[3].report_type == RequestReport.final_narrative_type_name
    assert @request1.request_reports.last.report_type == RequestReport.final_eval_type_name

    assert @request1.grant_id
  end

  test "test that approve a less than 1 year duration request to become a grant for an existing organization adds 2 request documents and creates the grant ID" do
    login_as_user_with_role Program.grants_administrator_role_name

    # Setup an extra grant
    @request2 = GrantRequest.make :state => 'granted', :program => @program, :program_organization => @org, :amount_recommended => 45000, :duration_in_months => 18, :granted => 1
    assert_equal 1, @org.grants.size

    @request1.state = 'pending_grant_promotion'
    @request1.duration_in_months = 11
    @request1.amount_recommended = 45000
    @request1.save
    assert !@request1.grant_id
    check_models_are_not_updated{put :edit, :id => @request1.to_param, :approve_grant_details => true}
    assert_template :partial => '_approve_grant_details'
    @request1 = assigns(:model)
    assert @request1.grant_agreement_at
    assert_equal @org, @request1.program_organization
    assert_equal 3, @request1.request_reports.size
    assert @request1.request_reports[2].report_type == RequestReport.final_eval_type_name
    assert_equal 1, @request1.request_transactions.size
    assert_equal @request1.amount_recommended, @request1.request_transactions.first.amount_due

    assert @request1.grant_id
  end

  test "test approving a short durection ER untrusted org request" do
    program = Program.make
    login_as_user_with_role Program.grants_administrator_role_name, program
    er_org = Organization.make :tax_class => bp_attrs[:er_tax_status]
    er_request = GrantRequest.make :state => 'pending_grant_promotion', :program => program, :program_organization => er_org, :amount_recommended => 45000, :duration_in_months => 11
    check_models_are_not_updated{put :edit, :id => er_request.to_param, :approve_grant_details => true}
    assert_template :partial => '_approve_grant_details'
    er_request = assigns(:model)
    assert er_request.grant_agreement_at
    assert_equal 5, er_request.request_reports.size
    assert_equal 3, er_request.request_transactions.size
  end

  test "test approving a long duration ER untrusted org request" do
    program = Program.make
    login_as_user_with_role Program.grants_administrator_role_name, program
    er_org = Organization.make :tax_class => bp_attrs[:er_tax_status]
    er_request = GrantRequest.make :state => 'pending_grant_promotion', :program => program, :program_organization => er_org, :amount_recommended => 45000, :duration_in_months => 18
    assert_equal er_org, er_request.program_organization
    check_models_are_not_updated{put :edit, :id => er_request.to_param, :approve_grant_details => true}
    assert assigns(:approve_grant_details_error)
  end

  test "test approving a short durection ER trusted org request" do
    program = Program.make
    login_as_user_with_role Program.grants_administrator_role_name, program
    er_org = Organization.make :tax_class => bp_attrs[:er_tax_status]
    er_grant = GrantRequest.make :state => 'granted', :program => program, :program_organization => er_org, :amount_recommended => 45000, :duration_in_months => 18, :granted => true
    er_request = GrantRequest.make :state => 'pending_grant_promotion', :program => program, :program_organization => er_org, :amount_recommended => 45000, :duration_in_months => 11
    check_models_are_not_updated{put :edit, :id => er_request.to_param, :approve_grant_details => true}
    assert_template :partial => '_approve_grant_details'
    er_request = assigns(:model)
    assert er_request.grant_agreement_at
    assert_equal 3, er_request.request_reports.size
    assert_equal 2, er_request.request_transactions.size
  end

  test "test advancing a long duration ER trusted org request in the grant workflow" do
    program = Program.make
    login_as_user_with_role Program.grants_administrator_role_name, program
    er_org = Organization.make :tax_class => bp_attrs[:er_tax_status]
    er_grant = GrantRequest.make :state => 'granted', :program => program, :program_organization => er_org, :amount_recommended => 45000, :duration_in_months => 18, :granted => 1
    er_request = GrantRequest.make :state => 'pending_grant_promotion', :program => program, :program_organization => er_org, :amount_recommended => 45000, :duration_in_months => 18
    assert er_request.has_tax_class?

    check_models_are_not_updated{put :edit, :id => er_request.to_param, :approve_grant_details => true}
    assert_template :partial => '_approve_grant_details'
    er_request = assigns(:model)
    assert er_request.grant_agreement_at
    assert_equal 1, er_org.grants.size
    assert_equal 5, er_request.request_reports.size
    assert_equal 3, er_request.request_transactions.size
  end

  test "test approving a long duration ER trusted org request" do
    program = Program.make
    login_as_user_with_role Program.grants_administrator_role_name, program
    er_org = Organization.make :tax_class => bp_attrs[:er_tax_status]
    er_grant = GrantRequest.make :state => 'granted', :program => program, :program_organization => er_org, :amount_recommended => 45000, :duration_in_months => 18, :granted => true
    er_request = GrantRequest.make :state => 'pending_grant_promotion', :program => program, :program_organization => er_org, :amount_recommended => 45000, :duration_in_months => 18
    assert er_request.has_tax_class?
    assert_equal er_org, er_request.program_organization
    check_models_are_updated{put :update, :id => er_request.to_param, :event_action => 'become_grant', :grant_request => {:grant_agreement_at => Time.now}}
    assert_equal 'granted', er_request.reload().state
  end

  test "should get index for multiple pages of contents" do
    30.times {GrantRequest.make :program => @program, :program_organization => @org, :base_request_id => nil}
    get :index
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  test "should get index with program_id" do
    get :index, :program_id => [@program.id]
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  test "should get index with funding_agreement_from_date" do
    get :index, :funding_agreement_from_date => [Time.now.mdy]
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  test "should get index with funding_agreement_to_date" do
    get :index, :funding_agreement_to_date => [Time.now.mdy]
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  test "should get CSV non-grants index" do
    get :index, :granted => [0], :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  test "should get CSV grants index" do
    get :index, :granted => [1], :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request" do
    assert_difference('GrantRequest.count') do
      post :create, :grant_request => { :project_summary => Sham.sentence, :program_organization_id => @org.id, :duration_in_months => 12, :program_id => @program.id, :amount_requested => 45000 }
    end
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{grant_request_path(assigns(:grant_request))}$/
  end

  test "should create role grantee org owner user" do
    assert_difference('Request.count') do
      post :create, :grant_request => { :project_summary => Sham.sentence, :program_organization_id => @org.id, :grantee_org_owner_id => @user1.id, :duration_in_months => 12, :amount_requested => 45000, :program_id => @program.id }
    end
    request = assigns(:grant_request)
    assert_not_nil request
    assert_not_nil request.reload.grantee_org_owner
    assert_equal @user1.id, request.grantee_org_owner.id

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{grant_request_path(assigns(:grant_request))}$/
  end

  test "should show request" do
    get :show, :id => @request1.to_param
    assert_response :success
  end

  test "should show request audit" do
    get :show, :id => @request1.to_param, :audit_id => @request1.audits.first.to_param
    assert_response :success
  end

  test "should show request finance tracker" do
    get :show, :id => @request1.to_param, :mode => 'finance_tracker'
    assert_response :success
  end

  test "try to show a deleted request" do
    @request1.update_attributes :deleted_at => Time.now
    get :show, :id => @request1.to_param
    assert_response :success
    assert @response.body.index "Could not find detail record in system"
  end

  test "try to show a granted request" do
    @request1.update_attributes :state => "granted"
    get :show, :id => @request1.to_param, :finance_tracker => 1
    assert_redirected_to granted_request_path(assigns(:model), :finance_tracker => 1)
  end

  test "should get edit" do
    get :edit, :id => @request1.to_param
    assert_response :success
  end

  test "should update request" do
    put :update, :id => @request1.to_param, :grant_request => { }
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{grant_request_path}$/
  end

  test "should destroy request" do
    delete :destroy, :id => @request1.to_param
    assert_not_nil @request1.reload().deleted_at
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{grant_request_path}$/
  end

  test "test filter display" do
    get :index, :view => 'filter'
  end

  test "should not be allowed to edit if somebody else is editing" do
    login_as_user_with_role Program.program_associate_role_name
    @request1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @request1.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    login_as_user_with_role Program.program_associate_role_name
    @request1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @request1.to_param, :organization => {}
    assert assigns(:not_editable)
  end

  test "try to cancel a grant" do
    login_as_user_with_role Program.grants_administrator_role_name
    @request1.state = 'granted'
    @request1.granted = true
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'cancel_grant'}
    assert_equal 'canceled', @request1.reload().state
    assert flash[:info]
  end

  test "show warnings related to funding sources" do
    login_as_user_with_role Program.program_associate_role_name
    @request1.update_attributes :display_warnings => true
    put :hide_funding_warnings, :id => @request1.to_param
    assert_equal false, @request1.reload().display_warnings?
    assert_redirected_to grant_request_path(assigns(:model))
  end

  test "fail validation and make sure request does not save" do
    put :update, :id => @request1.to_param, :grant_request => {:program_id => '' }
    assert_not_nil Request.find(@request1.id).program_id
  end

  test "test date saving" do
    put :update, :id => @request1.to_param, :grant_request => {:request_received_at => "7/7/1972"}
    assert_equal Request.find(@request1.id).request_received_at.to_a[0..7], Time.parse("7/7/1972").to_a[0..7]
  end



  # TODO ESH: need to test the calculate_button_names method to make sure we show the edit/delete/reject/un-reject/send-back buttons at the right times with the right names
end
