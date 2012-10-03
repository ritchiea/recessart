require 'test_helper'

class ModalReportsControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:models)
  end
  
  test "should get show with funding allocations by time plot" do
    controller = ModalReportsController.new
    reports = controller.insta_show_report_list
    rep = reports.select{|rep| rep.is_a? FundingAllocationsByTimeReport}.first
    get :show, :id => rep.report_id
    assert @response.body =~ /visualizations/
    assert @response.body.index(rep.report_label) > 0
  end
  
  test "should get show with funding allocations by time filter" do
    controller = ModalReportsController.new
    reports = controller.insta_show_report_list
    rep = reports.select{|rep| rep.is_a? FundingAllocationsByTimeReport}.first
    get :show, :id => rep.report_id, :fluxxreport_filter => 1
    assert_response :success
    # TODO ESH: what else can we check for here
  end
  

end
