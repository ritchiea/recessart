require 'test_helper'

class BankAccountTest < ActiveSupport::TestCase
  def setup
    @bank_account = BankAccount.make
  end
  
  test "truth" do
    assert true
  end
end