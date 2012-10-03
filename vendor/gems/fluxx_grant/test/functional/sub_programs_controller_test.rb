require 'test_helper'

class SubProgramsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @SubProgram = SubProgram.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sub_programs)
  end
  
  test "autocomplete" do
    lookup_instance = SubProgram.make
    get :index, :name => lookup_instance.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @SubProgram.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert_equal @SubProgram.id, a.first['value']
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sub_program" do
    assert_difference('SubProgram.count') do
      post :create, :sub_program => { :name => 'some random name for you', :program_id => 1 }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{sub_program_path(assigns(:sub_program))}$/
  end

  test "should show sub_program" do
    get :show, :id => @SubProgram.to_param
    assert_response :success
  end

  test "should show sub_program with documents" do
    model_doc1 = ModelDocument.make(:documentable => @SubProgram)
    model_doc2 = ModelDocument.make(:documentable => @SubProgram)
    get :show, :id => @SubProgram.to_param
    assert_response :success
  end
  
  test "should show sub_program with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @SubProgram, :group => group
    group_member2 = GroupMember.make :groupable => @SubProgram, :group => group
    get :show, :id => @SubProgram.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @SubProgram.to_param
    assert_response :success
  end

  test "should update sub_program" do
    put :update, :id => @SubProgram.to_param, :sub_program => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{sub_program_path(assigns(:sub_program))}$/
  end

  test "should destroy sub_program" do
    assert_difference('SubProgram.count', -1) do
      delete :destroy, :id => @SubProgram.to_param
    end
  end
end
