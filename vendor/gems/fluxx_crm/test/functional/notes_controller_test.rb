require 'test_helper'

class NotesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @note1 = Note.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:notes)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create note" do
    org = Organization.make
    assert_difference('Note.count') do
      post :create, :note => { :note => 'some random note for you', :notable_id => org.id, :notable_type => org.class.name}
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{note_path(assigns(:note))}$/
  end

  test "should show note" do
    get :show, :id => @note1.to_param
    assert_response :success
  end
  
  test "should show note audit" do
    get :show, :id => @note1.to_param, :audit_id => @note1.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @note1.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @note1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @note1.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @note1.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @note1.to_param, :note => {}
    assert assigns(:not_editable)
  end

  test "should update note" do
    put :update, :id => @note1.to_param, :note => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{note_path(assigns(:note))}$/
  end

  test "should destroy note" do
    delete :destroy, :id => @note1.to_param
    assert_not_nil @note1.reload().deleted_at 
  end
end
