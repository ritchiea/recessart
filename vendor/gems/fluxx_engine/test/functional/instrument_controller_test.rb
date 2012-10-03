require 'test_helper'

class InstrumentsControllerTest < ActionController::TestCase
  setup do
    @instrument = Instrument.make
    setup_multi
    @user = User.make
    login_as @user
  end
  
  test "should get index with all instruments deleted" do
    Instrument.delete_all
    get :index
    assert assigns(:instruments).blank?
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:instruments)
  end
  
  test "should get list of records by ID autocomplete" do
    instrument1 = Instrument.make
    instrument2 = Instrument.make
    instrument3 = Instrument.make
    get :index, :format => :autocomplete, :find_by_id => true, :id => [instrument1.id, instrument2.id, instrument3.id]
    assert_equal 3, assigns(:instruments).size
    assert assigns(:instruments).include?(instrument2)
    assert !assigns(:instruments).include?(@instrument)
  end

  test "should get list of records by JSON" do
    instrument1 = Instrument.make
    instrument2 = Instrument.make
    instrument3 = Instrument.make
    get :index, :format => :json, :find_by_id => true, :id => [instrument1.id, instrument2.id, instrument3.id]
    assert_equal 3, assigns(:instruments).size
    instruments = @response.body.de_json
    assert instruments.map{|instr| instr['instrument']['id']}.include? instrument1.id
  end

  test "should get index check on pre and post and format" do
    get :index, :format => :xml
    assert response.headers[:pre_invoked]
    assert response.headers[:post_invoked]
    assert response.headers[:format_invoked]
  end
  
  test "should get index with average index plot" do
    controller = InstrumentsController.new
    reports = controller.insta_index_report_list
    avg_rep = reports.select{|rep| rep.is_a? AverageInstrumentsReport}.first
    get :index, :fluxxreport_id => avg_rep.report_id
    assert @response.body =~ /visualizations/
    assert @response.body =~ /#{avg_rep.report_label}/
  end
  
  test "should get index with total index plot" do
    controller = InstrumentsController.new
    reports = controller.insta_index_report_list
    total_rep = reports.select{|rep| rep.is_a? TotalInstrumentsReport}.first
    get :index, :fluxxreport_id => total_rep.report_id
    assert @response.body =~ /visualizations/
    assert @response.body =~ /#{total_rep.report_label}/
  end
  
  test "should get show document" do
    controller = InstrumentsController.new
    reports = controller.insta_index_report_list
    total_rep = reports.select{|rep| rep.is_a? TotalInstrumentsReport}.first
    get :index, :fluxxreport_id => total_rep.report_id, :document => 1
    assert_response :success
  end

  test "should get index with pagination" do
    instruments = (1..51).map {Instrument.make}
    get :index
    assert_response :success
    assert_not_nil assigns(:instruments)
  end
  
  test "should get default CSV index" do
    instruments = (1..9).map {Instrument.make}
    instruments << @instrument
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:instruments)
    rows = @response.body.split "\n"
    assert_equal (instruments.size + 1), rows.size # make sure we have the same number of rows in csv + an extra one for the header
    instruments.each do |instrument|
      assert (@response.body =~ /#{instrument.id.to_s}/)
    end
  end
  
  test "should get default XLS index" do
    instruments = (1..9).map {Instrument.make}
    instruments << @instrument
    get :index, :format => 'xls'
    assert_response :success
    assert_not_nil assigns(:instruments)
    rows = @response.body.split "<Row>"
    assert_equal (instruments.size + 2), rows.size # make sure we have the same number of rows in csv + an extra one for the header and the markup that comes before the first row
    instruments.each do |instrument|
      assert (@response.body =~ /#{instrument.id.to_s}/)
    end
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  test "should get new check on pre and post" do
    get :new
    assert response.headers[:pre_invoked]
    assert response.headers[:post_invoked]
    assert response.headers[:format_invoked]
  end

  test "should create instrument" do
    assert_difference('Instrument.count') do
      post :create, :instrument => @instrument.attributes
    end
  end
  test "should create check on pre and post" do
    post :create, :instrument => @instrument.attributes
    assert response.headers[:pre_invoked]
    assert response.headers[:post_invoked]
    assert response.headers[:format_invoked]
  end

  test "should show instrument" do
    get :show, :id => @instrument.to_param
    assert_response :success
  end
  test "should get show check on pre and post" do
    get :show, :id => @instrument.to_param
    assert response.headers[:pre_invoked]
    assert response.headers[:post_invoked]
    assert response.headers[:format_invoked]
  end

  test "should get edit" do
    get :edit, :id => @instrument.to_param
    assert_response :success
  end
  test "should get edit check on pre and post" do
    get :edit, :id => @instrument.to_param
    assert response.headers[:pre_invoked]
    assert response.headers[:post_invoked]
    assert response.headers[:format_invoked]
  end

  test "should update instrument" do
    put :update, :id => @instrument.to_param, :instrument => @instrument.attributes
  end
  test "should get update check on pre and post" do
    put :update, :id => @instrument.to_param, :instrument => @instrument.attributes
    assert response.headers[:pre_invoked]
    assert response.headers[:post_invoked]
    assert response.headers[:format_invoked]
  end

  test "should not be able to update a locked instrument" do
    local_current_user = @user
    
    locking_user = User.make
    @instrument.update_attributes :locked_by => locking_user, :locked_until => (Time.now + 5.minutes)
    new_name = @instrument.name + "_new"
    put :update, :id => @instrument.to_param, :instrument => {:name => new_name}
    assert @instrument.reload.name != new_name
  end

  test "should destroy instrument" do
    assert_difference('Instrument.count', 0) do
      delete :destroy, :id => @instrument.to_param
    end
    
    assert @instrument.reload.deleted_at
  end
  test "should get destroy check on pre and post" do
    delete :destroy, :id => @instrument.to_param
    assert response.headers[:pre_invoked]
    assert response.headers[:post_invoked]
    assert response.headers[:format_invoked]
  end
  
  test "multiple attribute filter" do
    lookup_instrument1 = Instrument.make
    lookup_instrument2 = Instrument.make
    get :index, :instrument => {:id => [lookup_instrument1.id, lookup_instrument2.id]}, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    a = a.sort_by{|elem| elem['value']}
    assert_equal lookup_instrument1.name, a.first['label']
    assert_equal lookup_instrument1.id, a.first['value']
    assert_equal lookup_instrument2.name, a.second['label']
    assert_equal lookup_instrument2.id, a.second['value']
  end
  
  test "make sure that we can get the list of reports" do
    controller = InstrumentsController.new
    assert controller.respond_to? :insta_report_list
    assert controller.insta_report_list
    assert_equal 2, controller.insta_report_list.size
    assert_equal controller.insta_report_list.first.class.name.hash, controller.insta_report_list.first.report_id
    assert controller.insta_report_list.map{|rep| rep.class}.include?(TotalInstrumentsReport)
    assert_equal 0, controller.insta_show_report_list.size
    assert controller.insta_index_report_list.first.is_a?(TotalInstrumentsReport)
    assert controller.insta_index_report_list.last.is_a?(AverageInstrumentsReport)
  end
end
