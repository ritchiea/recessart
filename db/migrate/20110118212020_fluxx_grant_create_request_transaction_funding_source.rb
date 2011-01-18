class FluxxGrantCreateRequestTransactionFundingSource < ActiveRecord::Migration
  def self.up
    create_table "request_transaction_funding_sources", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_funding_source_id, :null => true, :limit => 12
      t.integer :amount
    end

    add_constraint 'request_transaction_funding_sources', 'request_transaction_funding_sources_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'request_transaction_funding_sources', 'request_transaction_funding_sources_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'request_transaction_funding_sources', 'request_transaction_funding_sources_fundsrc_id', 'request_funding_source_id', 'request_funding_sources', 'id'
  end

  def self.down
    drop_table "request_transaction_funding_sources"
  end
end