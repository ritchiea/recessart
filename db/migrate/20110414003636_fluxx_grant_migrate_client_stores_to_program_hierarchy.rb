class FluxxGrantMigrateClientStoresToProgramHierarchy < ActiveRecord::Migration
  def self.up
    
    # Switch dashboards from the old format to the new format for request hierarchy
    ClientStore.all.each do |client_store|
      if client_store.data
        funj = client_store.data.de_json
        [
          ["request[program_id][]", "request[sub_program_id][]", "request[request_hierarchy][]"],
          ["request_transaction[grant_program_ids][]","request_transaction[grant_sub_program_ids][]", "request_transaction[request_hierarchy][]"],
          ["request_report[grant_program_ids][]","request_report[grant_sub_program_ids][]", "request_report[request_hierarchy][]"],
        ].each do |triple_var|
          program_name, sub_program_name, hierarchy_name = triple_var
          funj['cards'].each do |card|
            if data_attrs = card['listing']['data']
              elements_to_delete = []
              programs = data_attrs.map do |attr_hash|
                if attr_hash["name"] == program_name
                  program = Program.find attr_hash["value"] rescue nil
                  elements_to_delete << attr_hash
                  program
                elsif attr_hash["name"] == sub_program_name
                  sub_program = SubProgram.find attr_hash["value"] rescue nil
                  elements_to_delete << attr_hash
                  sub_program
                end
              end.compact
              elements_to_delete.each {|attr_hash| data_attrs.delete(attr_hash) rescue nil}
              
              # If we have programs that match sub-programs, remove them from the map because they will be OR'd and should not be
              programs_to_delete = []
              programs.each do |prog|
                if prog.is_a?(SubProgram)
                  programs.each do |other_prog|
                    programs_to_delete << other_prog if other_prog.is_a?(Program) && other_prog.id == prog.program.id
                  end
                end
              end
              programs_to_delete.each {|prog| programs.delete(prog) rescue nil}
              
              hierarchy_tuple = programs.map do |program|
                if program.is_a? SubProgram
                  "#{program.program.id}-#{program.id}--"
                elsif program.is_a? Program
                  "#{program.id}---"
                end
              end.compact.join(',')
              data_attrs << {"name" => hierarchy_name, "value" => hierarchy_tuple} unless hierarchy_tuple.blank?
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