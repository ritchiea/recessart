class FluxxGrantAddSubInitiativeProgramToRequestFundingSource < ActiveRecord::Migration
  def self.up
    add_column :request_funding_sources, :sub_program_id, :integer
    add_constraint 'request_funding_sources', 'rfs_sub_program_id', 'sub_program_id', 'sub_programs', 'id'
    add_column :request_funding_sources, :sub_initiative_id, :integer
    add_constraint 'request_funding_sources', 'rfs_sub_initiative_id', 'sub_initiative_id', 'sub_initiatives', 'id'
  end

  def self.down
    remove_constraint 'request_funding_sources', 'rfs_sub_initiative_id'
    remove_column :request_funding_sources, :sub_initiative_id
    remove_constraint 'request_funding_sources', 'rfs_sub_program_id'
    remove_column :request_funding_sources, :sub_program_id
  end
end