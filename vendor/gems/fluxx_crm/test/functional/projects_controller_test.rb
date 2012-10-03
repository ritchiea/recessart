require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @project1 = Project.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post :create, :project => { :title => 'some random title for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{project_path(assigns(:project))}$/
  end

  test "should show project" do
    get :show, :id => @project1.to_param
    assert_response :success
  end

  test "should show project with documents" do
    model_doc1 = ModelDocument.make(:documentable => @project1)
    model_doc2 = ModelDocument.make(:documentable => @project1)
    get :show, :id => @project1.to_param
    assert_response :success
  end
  
  test "should show project with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @project1, :group => group
    group_member2 = GroupMember.make :groupable => @project1, :group => group
    get :show, :id => @project1.to_param
    assert_response :success
  end
  
  test "should show project with notes" do
    note1 = Note.make(:notable => @project1)
    note2 = Note.make(:notable => @project1)
    get :show, :id => @project1.to_param
    assert_response :success
  end
  
  test "should show project with audits" do
    Audit.make :auditable_id => @project1.to_param, :auditable_type => @project1.class.name
    get :show, :id => @project1.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @project1.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @project1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @project1.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @project1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @project1.to_param, :project => {}
    assert assigns(:not_editable)
  end

  test "should update project" do
    put :update, :id => @project1.to_param, :project => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{project_path(assigns(:project))}$/
  end

  test "should destroy project" do
    delete :destroy, :id => @project1.to_param
    assert_not_nil @project1.reload().deleted_at 
  end
  
  
  
end
