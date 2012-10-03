require 'test_helper'

class WorkTasksControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @WorkTask = WorkTask.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
  assert_not_nil assigns(:work_tasks)
  end

  test "autocomplete" do
    lookup_instance = WorkTask.make
    get :index, :name => lookup_instance.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @WorkTask.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@WorkTask.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create work_task" do
    assert_difference('WorkTask.count') do
      post :create, :work_task => { :name => 'some random name for you', :task_text => 'another random task text' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{work_task_path(assigns(:work_task))}$/
  end

  test "should show work_task" do
    get :show, :id => @WorkTask.to_param
    assert_response :success
  end

  test "should show work_task with documents" do
    model_doc1 = ModelDocument.make(:documentable => @WorkTask)
    model_doc2 = ModelDocument.make(:documentable => @WorkTask)
    get :show, :id => @WorkTask.to_param
    assert_response :success
  end
  
  test "should show work_task with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @WorkTask, :group => group
    group_member2 = GroupMember.make :groupable => @WorkTask, :group => group
    get :show, :id => @WorkTask.to_param
    assert_response :success
  end
  
  test "should show work_task with audits" do
    Audit.make :auditable_id => @WorkTask.to_param, :auditable_type => @WorkTask.class.name
    get :show, :id => @WorkTask.to_param
    assert_response :success
  end
  
  test "should show work_task audit" do
    get :show, :id => @WorkTask.to_param, :audit_id => @WorkTask.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @WorkTask.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @WorkTask.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @WorkTask.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @WorkTask.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @WorkTask.to_param, :work_task => {}
    assert assigns(:not_editable)
  end

  test "should update work_task" do
    put :update, :id => @WorkTask.to_param, :work_task => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{work_task_path(assigns(:work_task))}$/
  end

  test "should destroy work_task" do
    delete :destroy, :id => @WorkTask.to_param
    assert_not_nil @WorkTask.reload().deleted_at 
  end
end
