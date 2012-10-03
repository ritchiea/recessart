require 'test_helper'

class MultiElementValuesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @multi_element_group = MultiElementGroup.make :target_class_name => "Object"
    @multi_element_value = MultiElementValue.make :multi_element_group => @multi_element_group
  end
  
  test "should confirm that name_exists" do
    get :index, :name => @multi_element_value.value, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@multi_element_value.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create multi_element_value" do
    assert_difference('MultiElementValue.count') do
      post :create, :multi_element_value => { :value => 'some random name for you', :multi_element_group_id => @multi_element_group.id }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{multi_element_value_path(assigns(:multi_element_value))}$/
  end

  test "should show multi_element_value" do
    get :show, :id => @multi_element_value.to_param
    assert_response :success
  end

  test "should show multi_element_value with documents" do
    model_doc1 = ModelDocument.make(:documentable => @multi_element_value)
    model_doc2 = ModelDocument.make(:documentable => @multi_element_value)
    get :show, :id => @multi_element_value.to_param
    assert_response :success
  end
  
  test "should show multi_element_value with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @multi_element_value, :group => group
    group_member2 = GroupMember.make :groupable => @multi_element_value, :group => group
    get :show, :id => @multi_element_value.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @multi_element_value.to_param
    assert_response :success
  end

  test "should update multi_element_value" do
    put :update, :id => @multi_element_value.to_param, :multi_element_value => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{multi_element_value_path(assigns(:multi_element_value))}$/
  end
end
