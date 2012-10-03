require 'test_helper'

class WikiDocumentTemplatesControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @project = Project.make
    @wiki_document_template1 = WikiDocumentTemplate.make
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wiki_document_template" do
    assert_difference('WikiDocumentTemplate.count') do
      post :create, :wiki_document_template => { :model_type => Organization.name, :document => Sham.sentence}
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{wiki_document_template_path(assigns(:wiki_document_template))}$/
  end

  test "should show wiki_document_template" do
    get :show, :id => @wiki_document_template1.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @wiki_document_template1.to_param
    assert_response :success
  end

  test "should update wiki_document_template" do
    put :update, :id => @wiki_document_template1.to_param, :wiki_document_template => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{wiki_document_template_path(assigns(:wiki_document_template))}$/
  end

  test "should destroy wiki_document_template" do
    delete :destroy, :id => @wiki_document_template1.to_param
    assert_not_nil @wiki_document_template1.reload().deleted_at 
  end
end
