require 'test_helper'

class FipRequestsControllerTest < ActionController::TestCase

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
  
  def setup
    @org = Organization.make
    @program = Program.make
    @request1 = FipRequest.make :program => @program, :program_organization => @org, :base_request_id => nil
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
     [(FipRequest.all_workflow_states + FipRequest.all_sent_back_states).first].each do |cur_state|
      @controller = FipRequestsController.new
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

  test "try to have finance assistant approve an already approved request and make it closed" do
    login_as_user_with_role Program.finance_administrator_role_name
    @request1.state = 'closed'
    @request1.save
    check_models_are_not_updated{put :update, :id => @request1.to_param, :event_action => 'fip_close_grant'}
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

  test "try to have finance administrator approve an already approved request and make it closed" do
    login_as_user_with_role Program.finance_administrator_role_name
    @request1.state = 'granted'
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'fip_close_grant'}
    assert_equal 'closed', @request1.reload().state
    assert flash[:info]
  end
  
  test "should get index for multiple pages of contents" do
    30.times {FipRequest.make :program => @program, :program_organization => @org, :base_request_id => nil}
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
    assert_difference('FipRequest.count') do
      
      post :create, :fip_request => { :fip_title => Sham.sentence, :fip_type => bp_attrs[:fip_type_contract], :fip_projected_end_at => Time.now.to_s, :project_summary => Sham.sentence, :program_organization_id => @org.id, :duration_in_months => 12, :program_id => @program.id, :amount_requested => 45000 }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{fip_request_path(assigns(:fip_request))}$/
  end

  test "should create role grantee org owner user" do
    assert_difference('Request.count') do
      post :create, :fip_request => { :fip_title => Sham.sentence, :fip_type => bp_attrs[:fip_type_contract], :fip_projected_end_at => Time.now.to_s, :project_summary => Sham.sentence, :program_organization_id => @org.id, :grantee_org_owner_id => @user1.id, :duration_in_months => 12, :amount_requested => 45000, :program_id => @program.id }
    end
    request = assigns(:fip_request)
    assert_not_nil request
    assert_not_nil request.reload.grantee_org_owner
    assert_equal @user1.id, request.grantee_org_owner.id

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{fip_request_path(assigns(:fip_request))}$/
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

  test "should get edit" do
    get :edit, :id => @request1.to_param
    assert_response :success
  end

  test "should update request" do
    put :update, :id => @request1.to_param, :fip_request => { }
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{fip_request_path}$/
  end

  test "should destroy request" do
    delete :destroy, :id => @request1.to_param
    assert_not_nil @request1.reload().deleted_at 
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{fip_request_path}$/
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
    login_as_user_with_role Program.finance_administrator_role_name
    @request1.state = 'granted'
    @request1.granted = true
    @request1.save
    check_models_are_updated{put :update, :id => @request1.to_param, :event_action => 'cancel_grant'}
    assert_equal 'canceled', @request1.reload().state
    assert flash[:info]
  end 
  
  # TODO ESH: need to test the calculate_button_names method to make sure we show the edit/delete/reject/un-reject/send-back buttons at the right times with the right names
end