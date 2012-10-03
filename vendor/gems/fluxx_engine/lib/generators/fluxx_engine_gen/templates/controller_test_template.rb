require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @<%= controller_class_singular_table_name %> = <%= controller_class_singular_name %>.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= controller_class_plural_table_name %>)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:<%= controller_class_plural_table_name %>)
  end
  
  test "autocomplete" do
    lookup_instance = <%= controller_class_singular_name %>.make
    get :index, :name => lookup_instance.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @<%= controller_class_singular_table_name %>.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@<%= controller_class_singular_table_name %>.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create <%= controller_class_singular_table_name %>" do
    assert_difference('<%= controller_class_singular_name %>.count') do
      post :create, :<%= controller_class_singular_table_name %> => { :name => 'some random name for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{<%= controller_class_singular_table_name %>_path(assigns(:<%= controller_class_singular_table_name %>))}$/
  end

  test "should show <%= controller_class_singular_table_name %>" do
    get :show, :id => @<%= controller_class_singular_table_name %>.to_param
    assert_response :success
  end

  test "should show <%= controller_class_singular_table_name %> with documents" do
    model_doc1 = ModelDocument.make(:documentable => @<%= controller_class_singular_table_name %>)
    model_doc2 = ModelDocument.make(:documentable => @<%= controller_class_singular_table_name %>)
    get :show, :id => @<%= controller_class_singular_table_name %>.to_param
    assert_response :success
  end
  
  test "should show <%= controller_class_singular_table_name %> with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @<%= controller_class_singular_table_name %>, :group => group
    group_member2 = GroupMember.make :groupable => @<%= controller_class_singular_table_name %>, :group => group
    get :show, :id => @<%= controller_class_singular_table_name %>.to_param
    assert_response :success
  end
  
  test "should show <%= controller_class_singular_table_name %> with audits" do
    Audit.make :auditable_id => @<%= controller_class_singular_table_name %>.to_param, :auditable_type => @<%= controller_class_singular_table_name %>.class.name
    get :show, :id => @<%= controller_class_singular_table_name %>.to_param
    assert_response :success
  end
  
  test "should show <%= controller_class_singular_table_name %> audit" do
    get :show, :id => @<%= controller_class_singular_table_name %>.to_param, :audit_id => @<%= controller_class_singular_table_name %>.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @<%= controller_class_singular_table_name %>.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @<%= controller_class_singular_table_name %>.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @<%= controller_class_singular_table_name %>.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @<%= controller_class_singular_table_name %>.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @<%= controller_class_singular_table_name %>.to_param, :<%= controller_class_singular_table_name %> => {}
    assert assigns(:not_editable)
  end

  test "should update <%= controller_class_singular_table_name %>" do
    put :update, :id => @<%= controller_class_singular_table_name %>.to_param, :<%= controller_class_singular_table_name %> => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{<%= controller_class_singular_table_name %>_path(assigns(:<%= controller_class_singular_table_name %>))}$/
  end

  test "should destroy <%= controller_class_singular_table_name %>" do
    delete :destroy, :id => @<%= controller_class_singular_table_name %>.to_param
    assert_not_nil @<%= controller_class_singular_table_name %>.reload().deleted_at 
  end
end
