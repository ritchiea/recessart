class FluxxGrantCreateFundingSourceAllocationAuthority < ActiveRecord::Migration
  def self.up
    create_table "funding_source_allocation_authorities", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :amount, :null => true, :limit => 12
      t.integer :authority_id, :null => true, :limit => 12
      t.integer :funding_source_allocation_id, :null => true, :limit => 12
    end
    
    # Populate the funding source allocation authorities table from funding source allocations
    execute "insert into funding_source_allocation_authorities 
      (created_at, updated_at, created_by_id, updated_by_id, amount, authority_id, funding_source_allocation_id)
      select created_at, updated_at, created_by_id, updated_by_id, amount, authority_id, id from funding_source_allocations"
    
    execute "drop temporary table if exists fsss"
    execute "create temporary table fsss select id, funding_source_id, program_id, sub_program_id, initiative_id, sub_initiative_id, count(*) tot 
      from funding_source_allocations group by funding_source_id, program_id, sub_program_id, initiative_id, sub_initiative_id"

    # Need to update matching funding_source_allocation_authorities records to point to the fsss.id
    # Then remap rfs records to point to the coalesced funding_source_allocation record
    execute "update funding_source_allocation_authorities fsaa, fsss, funding_source_allocations fsa 
    set fsaa.funding_source_allocation_id = fsss.id 
    where 
    fsss.funding_source_id = fsa.funding_source_id and fsss.program_id = fsa.program_id and
    tot > 1 and fsss.id <> fsa.id
    and fsa.id = fsaa.funding_source_allocation_id"
    execute "update request_funding_sources rfs, fsss, funding_source_allocations fsa 
    set rfs.funding_source_allocation_id = fsss.id 
    where 
    fsss.funding_source_id = fsa.funding_source_id and fsss.program_id = fsa.program_id and
    tot > 1 and fsss.id <> fsa.id
    and fsa.id = rfs.funding_source_allocation_id"

    execute "update funding_source_allocation_authorities fsaa, fsss, funding_source_allocations fsa 
    set fsaa.funding_source_allocation_id = fsss.id 
    where 
    fsss.funding_source_id = fsa.funding_source_id and fsss.sub_program_id = fsa.sub_program_id and
    tot > 1 and fsss.id <> fsa.id
    and fsa.id = fsaa.funding_source_allocation_id"
    execute "update request_funding_sources rfs, fsss, funding_source_allocations fsa 
    set rfs.funding_source_allocation_id = fsss.id 
    where 
    fsss.funding_source_id = fsa.funding_source_id and fsss.sub_program_id = fsa.sub_program_id and
    tot > 1 and fsss.id <> fsa.id
    and fsa.id = rfs.funding_source_allocation_id"

    execute "update funding_source_allocation_authorities fsaa, fsss, funding_source_allocations fsa 
    set fsaa.funding_source_allocation_id = fsss.id 
    where 
    fsss.funding_source_id = fsa.funding_source_id and fsss.initiative_id = fsa.initiative_id and 
    tot > 1 and fsss.id <> fsa.id
    and fsa.id = fsaa.funding_source_allocation_id"
    execute "update request_funding_sources rfs, fsss, funding_source_allocations fsa 
    set rfs.funding_source_allocation_id = fsss.id 
    where 
    fsss.funding_source_id = fsa.funding_source_id and fsss.initiative_id = fsa.initiative_id and 
    tot > 1 and fsss.id <> fsa.id
    and fsa.id = rfs.funding_source_allocation_id"

    execute "update funding_source_allocation_authorities fsaa, fsss, funding_source_allocations fsa 
    set fsaa.funding_source_allocation_id = fsss.id 
    where 
    fsss.funding_source_id = fsa.funding_source_id and fsss.sub_initiative_id = fsa.sub_initiative_id and
    tot > 1 and fsss.id <> fsa.id
    and fsa.id = fsaa.funding_source_allocation_id"
    execute "update request_funding_sources rfs, fsss, funding_source_allocations fsa 
    set rfs.funding_source_allocation_id = fsss.id 
    where 
    fsss.funding_source_id = fsa.funding_source_id and fsss.sub_initiative_id = fsa.sub_initiative_id and
    tot > 1 and fsss.id <> fsa.id
    and fsa.id = rfs.funding_source_allocation_id"

    # Finally need to delete out the extra funding_source_allocation records (ones that are no long pointed to in the funding_source_allocation_authorities table)
    execute "drop temporary table if exists fsa_to_delete"
    execute "create temporary table fsa_to_delete select fsa.id 
      from funding_source_allocations fsa
      left outer join funding_source_allocation_authorities fsaa on fsaa.funding_source_allocation_id = fsa.id
      where fsaa.id is null and initiative_id is not null"

    execute "delete funding_source_allocations.* from funding_source_allocations, fsa_to_delete
    where funding_source_allocations.id = fsa_to_delete.id"
    
    # Recalc the sum for each funding_source_allocation recod
    execute "update funding_source_allocations fsa
     set amount=(select sum(amount) from funding_source_allocation_authorities fsaa where fsaa.funding_source_allocation_id = fsa.id)"
    
    add_constraint 'funding_source_allocation_authorities', 'fsa_authorities_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'funding_source_allocation_authorities', 'fsa_authorities_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'funding_source_allocation_authorities', 'fsa_authorities_authority_id', 'authority_id', 'multi_element_values', 'id'
    add_constraint 'funding_source_allocation_authorities', 'fsa_authorities_fsa_id', 'funding_source_allocation_id', 'funding_source_allocations', 'id'

    remove_constraint 'funding_source_allocations', 'funding_source_allocations_authority_id'
    change_table :funding_source_allocations do |t|
      t.remove :authority_id
    end
    
    # Fix the meg group
    execute "update multi_element_groups set target_class_name = 'FundingSourceAllocationAuthority', name = 'authority' where target_class_name = 'FundingSourceAllocation' and name = 'board_authorities'"
    
    # Fix some duplicate funding source allocation authorities
    execute "drop temporary table if exists dupe_fsaa"
    execute "create temporary table dupe_fsaa 
    select id, authority_id, funding_source_allocation_id, count(*) tot, sum(amount) amount_total from funding_source_allocation_authorities group by authority_id, funding_source_allocation_id"

    execute "update funding_source_allocation_authorities fsaa, dupe_fsaa
    set fsaa.amount = dupe_fsaa.amount_total
    where fsaa.id = dupe_fsaa.id
    and tot > 1"

    execute "delete fsaa.* from funding_source_allocation_authorities fsaa, dupe_fsaa
    where fsaa.id <> dupe_fsaa.id
    and fsaa.authority_id = dupe_fsaa.authority_id
    and fsaa.funding_source_allocation_id = dupe_fsaa.funding_source_allocation_id
    and tot > 1"
  end

  def self.down
    drop_table "funding_source_allocation_authorities"
    # A few other things are omitted here; don't want to down this migration....
  end
end