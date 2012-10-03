require 'test_helper'

class SubInitiativeTest < ActiveSupport::TestCase
  def setup
    @sub_initiative = SubInitiative.make
  end
  
  test "make sure the funding_source_allocations call does not blow up" do
    result = @sub_initiative.funding_source_allocations(:spending_year => 2010)
    result = @sub_initiative.funding_source_allocations
  end
  
  test "make sure the total_pipeline call does not blow up" do
    result = @sub_initiative.total_pipeline
    result = @sub_initiative.total_pipeline 'GrantRequest'
    result = @sub_initiative.total_pipeline ['GrantRequest']
    result = @sub_initiative.total_pipeline ['GrantRequest', 'FipRequest']
  end
  
  test "make sure the total_allocation call does not blow up" do
    result = @sub_initiative.total_allocation(:spending_year => 2010)
    result = @sub_initiative.total_allocation
  end
end