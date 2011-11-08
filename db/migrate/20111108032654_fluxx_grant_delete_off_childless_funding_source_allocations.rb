class FluxxGrantDeleteOffChildlessFundingSourceAllocations < ActiveRecord::Migration
  def self.up
    execute "create temporary table allocs_to_mark_deleted
      select funding_source_allocations.id, 
        (select count(*) from funding_source_allocation_authorities where funding_source_allocation_id = funding_source_allocations.id) child_count 
      from funding_source_allocations 
      having child_count = 0"
    execute "update funding_source_allocations, allocs_to_mark_deleted set funding_source_allocations.deleted_at = now() 
      where funding_source_allocations.id = allocs_to_mark_deleted.id"
  end

  def self.down
    
  end
end