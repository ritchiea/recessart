class FluxxGrantMigrateClientStoresToProgramHierarchy < ActiveRecord::Migration
  def self.up
    
    # Switch dashboards from the old format to the new format for request hierarchy
    ClientStore.all.each do |client_store|
      if client_store.data
        client_store.data = client_store.data.gsub /\{"name":"request\[sub_program_id\]\[\]","value":"(\d*)"\}/, '{"name":"request[request_hierarchy][]","value":"-\1--"}'
        client_store.data = client_store.data.gsub /\{"name":"request\[program_id\]\[\]","value":"(\d*)"\}/, '{"name":"request[request_hierarchy][]","value":"\1---"}'

        client_store.data = client_store.data.gsub /\{"name":"request_transaction\[grant_sub_program_ids\]\[\]","value":"(\d*)"\}/, '{"name":"request_transaction[request_hierarchy][]","value":"-\1--"}'
        client_store.data = client_store.data.gsub /\{"name":"request_transaction\[grant_program_ids\]\[\]","value":"(\d*)"\}/, '{"name":"request_transaction[request_hierarchy][]","value":"\1---"}'

        client_store.data = client_store.data.gsub /\{"name":"request_report\[grant_sub_program_ids\]\[\]","value":"(\d*)"\}/, '{"name":"request_report[request_hierarchy][]","value":"-\1--"}'
        client_store.data = client_store.data.gsub /\{"name":"request_report\[grant_program_ids\]\[\]","value":"(\d*)"\}/, '{"name":"request_report[request_hierarchy][]","value":"\1---"}'
        client_store.save
      end
    end
  end

  def self.down
    
  end
end