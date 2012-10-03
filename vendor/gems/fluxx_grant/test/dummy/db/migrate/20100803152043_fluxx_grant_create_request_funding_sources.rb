class FluxxGrantCreateRequestFundingSources < ActiveRecord::Migration
  def self.up
    create_table :request_funding_sources do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :funding_source_id, :program_id, :initiative_id, :null => true, :limit => 12
      t.string :document_file_name
      t.integer :funding_amount, :null => true, :limit => 12
      t.integer :locked_by_id, :null => true, :limit => 12
      t.datetime :locked_until, :null => true
    end
    add_index :request_funding_sources, :request_id
    add_index :request_funding_sources, :program_id
    add_index :request_funding_sources, :initiative_id
    add_index :request_funding_sources, :funding_source_id

    add_constraint 'request_funding_sources', 'request_funding_sources_request_id', 'request_id', 'requests', 'id'
    add_constraint 'request_funding_sources', 'request_funding_sources_program_id', 'program_id', 'programs', 'id'
    add_constraint 'request_funding_sources', 'request_funding_sources_initiative_id', 'initiative_id', 'initiatives', 'id'
    add_constraint 'request_funding_sources', 'request_funding_sources_funding_source_id', 'funding_source_id', 'funding_sources', 'id'
  end

  def self.down
    drop_table :request_funding_sources
  end
end