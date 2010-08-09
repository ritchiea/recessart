class FluxxGrantCreateRequestGeoStates < ActiveRecord::Migration
  def self.up
    create_table :request_geo_states do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :geo_state_id, :null => true, :limit => 12
    end
    add_index :request_geo_states, :request_id
    add_index :request_geo_states, :geo_state_id
    execute "alter table request_geo_states add constraint request_geo_states_request_id foreign key (request_id) references requests(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table request_geo_states add constraint request_geo_states_geo_state_id foreign key (geo_state_id) references geo_states(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :request_geo_states
  end
end