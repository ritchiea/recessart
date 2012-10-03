require 'test_helper'

class GrantedRequestsControllerTest < ActionController::TestCase
  def setup
    @org = Organization.make
    @program = Program.make
    @request1 = GrantRequest.make :program => @program, :program_organization => @org, :base_request_id => nil
    @user1 = User.make
    @user1.has_role! Program.program_officer_role_name, @program
    login_as @user1
  end

  test "test filter display" do
    get :index, :view => 'filter'
  end

  test "should show request" do
    get :show, :id => @request1.to_param
    assert_response :success
  end
  
  test "should get index with monthly grants count plot" do
    controller = GrantedRequestsController.new
    reports = controller.insta_index_report_list
    grant_count_rep = reports.select{|rep| rep.is_a? MonthlyGrantsCountReport}.first
    get :index, :fluxxreport_id => grant_count_rep.report_id
    assert @response.body =~ /visualizations/
    assert @response.body =~ /#{grant_count_rep.report_label}/
  end
  
  test "should get index with monthly grants money plot" do
    controller = GrantedRequestsController.new
    reports = controller.insta_index_report_list
    grant_money_rep = reports.select{|rep| rep.is_a? MonthlyGrantsMoneyReport}.first
    get :index, :fluxxreport_id => grant_money_rep.report_id
    assert @response.body =~ /visualizations/
    assert @response.body =~ /#{grant_money_rep.report_label}/
  end
end