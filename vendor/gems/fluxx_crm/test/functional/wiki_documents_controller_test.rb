require 'test_helper'

class WikiDocumentsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @project = Project.make
    @wiki_document1 = WikiDocument.make
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wiki_document" do
    assert_difference('WikiDocument.count') do
      post :create, :wiki_document => { :title => Sham.word, :note => Sham.sentence}
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{wiki_document_path(assigns(:wiki_document))}$/
  end

  test "should show wiki_document" do
    get :show, :id => @wiki_document1.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @wiki_document1.to_param
    assert_response :success
  end

  test "should get edit with document templates" do
    wiki_doc_template = WikiDocumentTemplate.make :model_type => @wiki_document1.model_type
    get :edit, :id => @wiki_document1.to_param
    assert_response :success
  end

  test "should update wiki_document" do
    put :update, :id => @wiki_document1.to_param, :wiki_document => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{wiki_document_path(assigns(:wiki_document))}$/
  end

  test "should destroy wiki_document" do
    delete :destroy, :id => @wiki_document1.to_param
    assert_not_nil @wiki_document1.reload().deleted_at 
  end
end
