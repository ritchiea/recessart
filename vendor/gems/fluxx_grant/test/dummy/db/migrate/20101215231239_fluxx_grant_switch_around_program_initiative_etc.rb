class FluxxGrantSwitchAroundProgramInitiativeEtc < ActiveRecord::Migration
  def self.up
    # get rid of referential integrity
    remove_constraint 'request_funding_sources', 'rfs_sub_initiative_id'
    remove_constraint 'request_funding_sources', 'request_funding_sources_funding_source_id'
    remove_constraint 'request_funding_sources', 'request_funding_sources_initiative_id'
    remove_constraint 'request_funding_sources', 'request_funding_sources_program_id'
    remove_constraint 'request_funding_sources', 'request_funding_sources_request_id'
    remove_constraint 'request_funding_sources', 'rfs_board_authority_id'
    remove_constraint 'request_funding_sources', 'rfs_sub_program_id'
    remove_constraint 'requests', 'requests_program_id'
    remove_constraint 'requests', 'requests_initiative_id'
    remove_constraint 'initiatives', 'initiatives_program_id'
    remove_constraint 'sub_initiatives', 'sub_initiative_sub_program_id'
    remove_constraint 'sub_programs', 'sub_program_initiative_id'
      
    # requests; initiative_id should be renamed to sub_program_id
    rename_column 'requests', 'initiative_id', 'sub_program_id'
    
    
    # rename sub_programs and initiatives
    rename_table 'sub_programs', 'tmp_table'
    rename_table 'initiatives', 'sub_programs'
    rename_table 'tmp_table', 'initiatives'
    
    # change initiatives column initiative_id to sub_program_id 
    rename_column 'initiatives', 'initiative_id', 'sub_program_id'
    # change sub_initiatives column sub_program_id to initiative_id
    rename_column 'sub_initiatives', 'sub_program_id', 'initiative_id'
    # rename_column 'sub_programs', 'initiative_id', 'program_id'

    # request_funding_sources swap initiative_id and sub_program_id 
    rename_column 'request_funding_sources', 'sub_program_id', 'tmp_initiative_id'
    rename_column 'request_funding_sources', 'initiative_id', 'sub_program_id'
    rename_column 'request_funding_sources', 'tmp_initiative_id', 'initiative_id'
    
    # resume referential integrity
    add_constraint 'sub_programs', 'sub_programs_program_id', 'program_id', 'programs', 'id'
    add_constraint 'initiatives', 'initiative_sub_program_id', 'sub_program_id', 'sub_programs', 'id'
    add_constraint 'sub_initiatives', 'sub_initiative_initiative_id', 'initiative_id', 'initiatives', 'id'
    add_constraint 'requests', 'requests_program_id', 'program_id', 'programs', 'id'
    add_constraint 'requests', 'requests_sub_program_id', 'sub_program_id', 'sub_programs', 'id'
    add_constraint 'request_funding_sources', 'rfs_sub_initiative_id', 'sub_initiative_id', 'sub_initiatives', 'id'
    add_constraint 'request_funding_sources', 'request_funding_sources_funding_source_id', 'funding_source_id', 'funding_sources', 'id'
    add_constraint 'request_funding_sources', 'request_funding_sources_initiative_id', 'initiative_id', 'initiatives', 'id'
    add_constraint 'request_funding_sources', 'request_funding_sources_program_id', 'program_id', 'programs', 'id'
    add_constraint 'request_funding_sources', 'request_funding_sources_request_id', 'request_id', 'requests', 'id'
    add_constraint 'request_funding_sources', 'rfs_board_authority_id', 'board_authority_id', 'multi_element_values', 'id'
    add_constraint 'request_funding_sources', 'rfs_sub_program_id', 'sub_program_id', 'sub_programs', 'id'
  end

  def self.down
    
  end
end