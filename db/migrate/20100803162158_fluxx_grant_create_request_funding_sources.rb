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

    execute "alter table request_funding_sources add constraint request_funding_sources_request_id foreign key (request_id) references requests(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table request_funding_sources add constraint request_funding_sources_program_id foreign key (program_id) references programs(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table request_funding_sources add constraint request_funding_sources_initiative_id foreign key (initiative_id) references initiatives(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table request_funding_sources add constraint request_funding_sources_funding_source_id foreign key (funding_source_id) references funding_sources(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :request_funding_sources
  end
end