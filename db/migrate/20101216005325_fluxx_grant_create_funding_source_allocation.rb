class FluxxGrantCreateFundingSourceAllocation < ActiveRecord::Migration
  def self.up
    create_table "funding_source_allocations", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :funding_source_id, :null => true, :limit => 12
      t.integer :program_id, :null => true, :limit => 12
      t.integer :sub_program_id, :null => true, :limit => 12
      t.integer :initiative_id, :null => true, :limit => 12
      t.integer :sub_initiative_id, :null => true, :limit => 12
      t.integer :authority_id, :null => true, :limit => 12
      t.integer :amount, :null => true, :limit => 12
      t.integer :retired, :boolean
      t.integer :locked_by_id, :null => true, :limit => 12
      t.datetime :locked_until, :deleted_at, :null => true
    end

    add_constraint 'funding_source_allocations', 'funding_source_allocations_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'funding_source_allocations', 'funding_source_allocations_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'funding_source_allocations', 'funding_source_allocations_funding_source_id', 'funding_source_id', 'funding_sources', 'id'
    add_constraint 'funding_source_allocations', 'funding_source_allocations_program_id', 'program_id', 'programs', 'id'
    add_constraint 'funding_source_allocations', 'funding_source_allocations_sub_program_id', 'sub_program_id', 'sub_programs', 'id'
    add_constraint 'funding_source_allocations', 'funding_source_allocations_initiative_id', 'initiative_id', 'initiatives', 'id'
    add_constraint 'funding_source_allocations', 'funding_source_allocations_sub_initiative_id', 'sub_initiative_id', 'sub_initiatives', 'id'
    add_constraint 'funding_source_allocations', 'funding_source_allocations_authority_id', 'authority_id', 'multi_element_values', 'id'
  end

  def self.down
    drop_table "funding_source_allocations"
  end
end