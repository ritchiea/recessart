require 'test_helper'

class RequestTransactionTest < ActiveSupport::TestCase
  def setup
    @request_transaction = RequestTransaction.make
  end
  
  test "test creating request transaction" do
    assert @request_transaction.id
  end
  
  test "create a req transaction and check initial state transition" do
    assert_equal 'tentatively_due', @request_transaction.state
  end
  
  test "take a report and mark_actually_due" do
    @request_transaction.mark_actually_due
    assert_equal 'due', @request_transaction.state
  end
  
  test "take a report and mark_actually_due from tentatively_due" do
    @request_transaction.state = 'tentatively_due'
    @request_transaction.save
    @request_transaction.mark_actually_due
    assert_equal 'due', @request_transaction.state
  end
  
  test "take a report and mark_paid" do
    @request_transaction.insta_fire_event :mark_paid, User.make
    assert_equal 'paid', @request_transaction.state
  end
  
  test "take a report and mark paid from tentatively_due" do
    @request_transaction.state = 'tentatively_due'
    @request_transaction.save
    @request_transaction.insta_fire_event :mark_paid, User.make
    assert_equal 'paid', @request_transaction.state
  end
  
  test "take a report and mark paid from mark_actually_due" do
    @request_transaction.state = 'due'
    @request_transaction.save
    @request_transaction.mark_paid
    assert_equal 'paid', @request_transaction.state
  end
end