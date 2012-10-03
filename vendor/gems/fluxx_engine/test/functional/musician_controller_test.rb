require 'test_helper'

class MusiciansControllerTest < ActionController::TestCase
  setup do
    @user = User.make
    login_as @user
    @musician = Musician.make
  end
  
  test "should be able to get insta_objects" do
    assert @controller.insta_index_object
    assert @controller.insta_show_object
    assert @controller.insta_new_object
    assert @controller.insta_edit_object
    assert @controller.insta_create_object
    assert @controller.insta_update_object
    assert @controller.insta_delete_object
    assert @controller.insta_related_object
  end
  

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:musicians)
  end

  test "should get index with pagination" do
    musicians = (1..51).map {Musician.make}
    get :index
    assert_response :success
    assert_not_nil assigns(:musicians)
  end
  
  test "should get default CSV index" do
    musicians = (1..9).map {Musician.make}
    musicians << @musician
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:musicians)
    rows = @response.body.split "\n"
    assert_equal (musicians.size + 1), rows.size # make sure we have the same number of rows in csv + an extra one for the header
    musicians.each do |musician|
      assert (@response.body =~ /#{musician.id.to_s}/)
    end
  end
  
  test "should get default XLS index" do
    musicians = (1..9).map {Musician.make}
    musicians << @musician
    get :index, :format => 'xls'
    assert_response :success
    assert_not_nil assigns(:musicians)
    rows = @response.body.split "<Row>"
    assert_equal (musicians.size + 2), rows.size # make sure we have the same number of rows in csv + an extra one for the header and the markup that comes before the first row
    musicians.each do |musician|
      assert (@response.body =~ /#{musician.id.to_s}/)
    end
  end
  
  test "should get autocomplete without condition" do
    get :index, :format => :autocomplete
    assert_response :success
    assert @response.body
    musicians = @response.body.de_json
    assert_equal 1, musicians.size
    assert_equal @musician.to_s, musicians.first['label']
    assert_equal @musician.id, musicians.first['value']
  end
  

  test "should get autocomplete with condition" do
    musicians = (1..9).map {Musician.make}
    last_musician = musicians.last
    get :index, :term => last_musician.first_name, :format => :autocomplete
    assert_response :success
    assert @response.body
    musicians = @response.body.de_json
    assert_equal 1, musicians.size
    assert_equal last_musician.to_s, musicians.first['label']
    assert_equal last_musician.id, musicians.first['value']
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create musician" do
    assert_difference('Musician.count') do
      post :create, :musician => @musician.attributes
    end
  end

  test "should not be able to create musician" do
    assert_difference('Musician.count', 0) do
      post :create, :musician => nil
    end
    
    assert !assigns(:model).id
  end

  test "should show musician" do
    get :show, :id => @musician.to_param
    assert_response :success
    assert_not_nil assigns(:related)
  end
  
  test "try to find non-existent musician" do
    max_musician_id = Musician.maximum :id
    get :show, :id => @musician.to_param
    assert_response :success
    assert_not_nil assigns(:related)
  end

  test "should get edit" do
    get :edit, :id => @musician.to_param
    assert_response :success
  end

  test "should update musician" do
    put :update, :id => @musician.to_param, :musician => @musician.attributes
  end

  test "get a validate error when updating musician" do
    put :update, :id => @musician.to_param, :musician => {:date_of_birth => '12-99-2008'}
    assert assigns(:model).instance_variable_get :@utc_time_validate_errors
  end
  
  test "should destroy musician" do
    assert_difference('Musician.count', -1) do
      delete :destroy, :id => @musician.to_param
    end
  end
end