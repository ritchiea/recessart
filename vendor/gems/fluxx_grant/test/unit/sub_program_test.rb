require 'test_helper'

class SubProgramTest < ActiveSupport::TestCase
  def setup
    @sub_program = SubProgram.make
  end
  
  test "make sure the funding_source_allocations call does not blow up" do
    result = @sub_program.funding_source_allocations(:spending_year => 2010)
    result = @sub_program.funding_source_allocations
  end
  
  test "make sure the total_pipeline call does not blow up" do
    result = @sub_program.total_pipeline
    result = @sub_program.total_pipeline 'GrantRequest'
    result = @sub_program.total_pipeline ['GrantRequest']
    result = @sub_program.total_pipeline ['GrantRequest', 'FipRequest']
  end
  
  test "make sure the total_allocation call does not blow up" do
    result = @sub_program.total_allocation(:spending_year => 2010)
    result = @sub_program.total_allocation
  end
end