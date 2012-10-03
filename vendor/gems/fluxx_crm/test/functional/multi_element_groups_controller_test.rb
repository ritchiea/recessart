require 'test_helper'

class MultiElementGroupsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @multi_element_group = MultiElementGroup.make(:target_class_name => "Object")
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:multi_element_groups)
  end
  
  test "autocomplete" do
    lookup_instance = MultiElementGroup.make(:target_class_name => "Object")
    get :index, :name => lookup_instance.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @multi_element_group.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@multi_element_group.id)
  end

  test "should show multi_element_group" do
    get :show, :id => @multi_element_group.to_param
    assert_response :success
  end

  test "should show multi_element_group with documents" do
    model_doc1 = ModelDocument.make(:documentable => @multi_element_group)
    model_doc2 = ModelDocument.make(:documentable => @multi_element_group)
    get :show, :id => @multi_element_group.to_param
    assert_response :success
  end
  
  test "should show multi_element_group with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @multi_element_group, :group => group
    group_member2 = GroupMember.make :groupable => @multi_element_group, :group => group
    get :show, :id => @multi_element_group.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @multi_element_group.to_param
    assert_response :success
  end

  test "should update multi_element_group" do
    put :update, :id => @multi_element_group.to_param, :multi_element_group => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{multi_element_group_path(assigns(:multi_element_group))}$/
  end
end
