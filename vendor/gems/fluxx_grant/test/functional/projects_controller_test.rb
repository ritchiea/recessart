require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @project1 = Project.make
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
end