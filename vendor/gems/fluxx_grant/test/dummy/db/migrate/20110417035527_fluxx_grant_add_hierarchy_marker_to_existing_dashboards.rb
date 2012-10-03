class FluxxGrantAddHierarchyMarkerToExistingDashboards < ActiveRecord::Migration
  def self.up
    # Switch dashboards from the old format to the new format for request hierarchy
    ClientStore.all.each do |client_store|
      if client_store.data
        funj = client_store.data.de_json
        funj['cards'].each do |card|
          if data_attrs = card['listing']['data']
            if data_attrs.any?{|element| element.to_json =~ /"name":"request\[/}
              data_attrs << {"name" => "request[hierarchies][]", "value" => "request_hierarchy"}
              data_attrs << {"name" => "request[hierarchies][]", "value" => "allocation_hierarchy"}
            end
            if data_attrs.any?{|element| element.to_json =~ /"name":"request_transaction\[/}
              data_attrs << {"name" => "request_transaction[hierarchies][]", "value" => "request_hierarchy"}
              data_attrs << {"name" => "request_transaction[hierarchies][]", "value" => "allocation_hierarchy"}
            end
            if data_attrs.any?{|element| element.to_json =~ /"name":"request_report\[/}
              data_attrs << {"name" => "request_report[hierarchies][]", "value" => "request_hierarchy"}
              data_attrs << {"name" => "request_report[hierarchies][]", "value" => "allocation_hierarchy"}
            end
          end
        end
        client_store.data = funj.to_json
        client_store.save
      end
    end
  end

  def self.down
    
  end
end