class FluxxGrantRelaxAuthorityMevConstraint < ActiveRecord::Migration
  def self.up
    remove_constraint 'funding_source_allocation_authorities', 'fsa_authorities_authority_id'
  end

  def self.down
    add_constraint 'funding_source_allocation_authorities', 'fsa_authorities_authority_id', 'authority_id', 'multi_element_values', 'id'
  end
end