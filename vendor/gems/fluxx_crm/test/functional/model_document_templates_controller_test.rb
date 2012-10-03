require 'test_helper'

class ModelDocumentTemplatesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @project = Project.make
    @model_document_template1 = ModelDocumentTemplate.make
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create model_document_template" do
    assert_difference('ModelDocumentTemplate.count') do
      post :create, :model_document_template => { :model_type => Organization.name, :document => Sham.sentence}
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{model_document_template_path(assigns(:model_document_template))}$/
  end

  test "should show model_document_template" do
    get :show, :id => @model_document_template1.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @model_document_template1.to_param
    assert_response :success
  end

  test "should update model_document_template" do
    put :update, :id => @model_document_template1.to_param, :model_document_template => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{model_document_template_path(assigns(:model_document_template))}$/
  end

  test "should destroy model_document_template" do
    delete :destroy, :id => @model_document_template1.to_param
    assert_not_nil @model_document_template1.reload().deleted_at 
  end
end
