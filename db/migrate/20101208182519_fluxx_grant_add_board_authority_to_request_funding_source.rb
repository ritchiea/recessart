class FluxxGrantAddBoardAuthorityToRequestFundingSource < ActiveRecord::Migration
  def self.up
    add_column :request_funding_sources, :board_authority_id, :integer
    add_constraint 'request_funding_sources', 'rfs_board_authority_id', 'board_authority_id', 'multi_element_values', 'id'
  end

  def self.down
    remove_constraint 'request_funding_sources', 'rfs_board_authority_id'
    remove_column :request_funding_sources, :board_authority_id
  end
end