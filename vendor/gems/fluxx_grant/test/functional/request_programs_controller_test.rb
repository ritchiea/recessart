require 'test_helper'

class RequestProgramsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    @grant_request = GrantRequest.make
    @program = Program.make
    login_as @user1
    @request_program = RequestProgram.make :request => @grant_request, :program => @program
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_programs)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:request_programs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request_program" do
    program2 = Program.make
    assert_difference('RequestProgram.count') do
      post :create, :request_program => { :request_id => @grant_request.id, :program_id => program2.id }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_program_path(assigns(:request_program))}$/
  end

  test "should show request_program" do
    get :show, :id => @request_program.to_param
    assert_response :success
  end

  test "should show request_program with documents" do
    model_doc1 = ModelDocument.make(:documentable => @request_program)
    model_doc2 = ModelDocument.make(:documentable => @request_program)
    get :show, :id => @request_program.to_param
    assert_response :success
  end
  
  test "should show request_program with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @request_program, :group => group
    group_member2 = GroupMember.make :groupable => @request_program, :group => group
    get :show, :id => @request_program.to_param
    assert_response :success
  end
  
  test "should show request_program with audits" do
    Audit.make :auditable_id => @request_program.to_param, :auditable_type => @request_program.class.name
    get :show, :id => @request_program.to_param
    assert_response :success
  end
  
  test "should show request_program audit" do
    get :show, :id => @request_program.to_param, :audit_id => @request_program.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @request_program.to_param
    assert_response :success
  end

  test "should update request_program" do
    put :update, :id => @request_program.to_param, :request_program => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{request_program_path(assigns(:request_program))}$/
  end

  test "should destroy request_program" do
    assert_difference('RequestProgram.count', -1) do
      delete :destroy, :id => @request_program.to_param
    end
  end
end
