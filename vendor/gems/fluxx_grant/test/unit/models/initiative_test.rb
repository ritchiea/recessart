require 'test_helper'

class InitiativeTest < ActiveSupport::TestCase
  test "ability to validate an initiative" do
    prog = Program.create :name => 'Fun Program'
    sub_prog = SubProgram.create :name => 'Fun sub Program', :program => prog
    initiative = Initiative.create
    assert_equal 3, initiative.errors.size
    initiative = Initiative.create :name => 'Fun Initiative'
    assert_equal 1, initiative.errors.size
    initiative = Initiative.create :name => 'Fun Initiative', :sub_program => sub_prog
    assert_not_nil initiative.id
  end
  
  test "ability to navigate to sub_initiatives" do
    prog = Program.create :name => 'Fun Program'
    sub_prog = SubProgram.create :name => 'Fun sub Program', :program => prog
    initiative = Initiative.create :name => 'Fun Program', :sub_program => sub_prog
    assert_not_nil initiative.sub_program.id
  end
  
  test "make sure the funding_source_allocations call does not blow up" do
    initiative = Initiative.create :name => 'Fun Program'
    result = initiative.funding_source_allocations(:spending_year => 2010)
    result = initiative.funding_source_allocations
  end
  
  test "make sure the total_pipeline call does not blow up" do
    initiative = Initiative.create :name => 'Fun Program'
    result = initiative.total_pipeline
    result = initiative.total_pipeline 'GrantRequest'
    result = initiative.total_pipeline ['GrantRequest']
    result = initiative.total_pipeline ['GrantRequest', 'FipRequest']
  end
  
  test "make sure the total_allocation call does not blow up" do
    initiative = Initiative.create :name => 'Fun Program'
    result = initiative.total_allocation(:spending_year => 2010)
    result = initiative.total_allocation
  end
  
end
