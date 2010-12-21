class FluxxGrantPopulateFundingSourceAllocations < ActiveRecord::Migration
  def self.up
    execute "insert into funding_source_allocations (created_at, updated_at, program_id, sub_program_id, initiative_id, sub_initiative_id, funding_source_id, authority_id)
    select now(), now(), program_id, sub_program_id, initiative_id, sub_initiative_id, funding_source_id, board_authority_id
    from request_funding_sources where funding_source_id is not null
    group by program_id, sub_program_id, initiative_id, sub_initiative_id, funding_source_id, board_authority_id"

    # add a funding_source_allocation_id column to request_funding_sources
    add_column :request_funding_sources, :funding_source_allocation_id, :integer
    add_constraint 'request_funding_sources', 'rfs_funding_source_allocation_id', 'funding_source_allocation_id', 'funding_source_allocations', 'id'
    
    # need to look up the funding_source_allocation_id to add to request_funding_sources
    # Inconvenient to do this in SQL because we have lots of cases where matching params may be null and SQL won't join when a column is null.  
    RequestFundingSource.all.each do |rfs|
      fsa = FundingSourceAllocation.where(:program_id => rfs.program_id, :sub_program_id => rfs.sub_program_id, :initiative_id => rfs.initiative_id, :sub_initiative_id => rfs.sub_initiative_id, :funding_source_id => rfs.funding_source_id, :authority_id => rfs.board_authority_id).first
      rfs.update_attribute :funding_source_allocation_id, fsa.id if fsa
    end

    # drop the now superfluous board_authority_id, funding_source_id, program_id, sub_program_id, initiative_id, sub_initiative_id columns from the request_funding_sources table
    remove_constraint 'request_funding_sources', 'rfs_board_authority_id'
    remove_column :request_funding_sources, :board_authority_id
    
    remove_constraint 'request_funding_sources', 'request_funding_sources_funding_source_id'
    remove_column :request_funding_sources, :funding_source_id
    
    remove_constraint 'request_funding_sources', 'request_funding_sources_program_id'
    remove_column :request_funding_sources, :program_id
    
    remove_constraint 'request_funding_sources', 'rfs_sub_program_id'
    remove_column :request_funding_sources, :sub_program_id
    
    remove_constraint 'request_funding_sources', 'request_funding_sources_initiative_id'
    remove_column :request_funding_sources, :initiative_id
    
    remove_constraint 'request_funding_sources', 'rfs_sub_initiative_id'
    remove_column :request_funding_sources, :sub_initiative_id
  end

  def self.down
  end
end