class FluxxGrantLimitAllocationProgramDesignationToOneField < ActiveRecord::Migration
  class FundingSourceAllocation < ActiveRecord::Base
  end

  def self.up
    # Make sure that funding source allocations all have only one designation; either program_id, sub_program_id, initiative_id or sub_initiative_id.
    # If more than one is present, it may get out of date if say a initiative_id switches from one program to another
    FundingSourceAllocation.all.each do |fsa|
      program_id = fsa.program_id if fsa.program_id
      sub_program_id = fsa.sub_program_id if fsa.sub_program_id
      initiative_id = fsa.initiative_id if fsa.initiative_id
      sub_initiative_id = fsa.sub_initiative_id if fsa.sub_initiative_id
      
      fsa.program_id = nil if fsa.sub_program_id || fsa.initiative_id || fsa.sub_initiative_id
      fsa.sub_program_id = nil if fsa.initiative_id || fsa.sub_initiative_id
      fsa.initiative_id = nil if fsa.sub_initiative_id
      fsa.save(false)
      # NOTE ESH: could do a lot more efficiently with a single SQL update, but this is only run once and I believe it is easier to understand this way
    end
    
  end

  def self.down
    
  end
end