# Centralize some complex queries used in multiple files
class FluxxGrantSphinxHelper
  def self.request_hierarchy
    "group_concat(CRC32(concat(ifnull(requests.program_id, ''), '-', '-', '-')), ',', 
        CRC32(concat('-', ifnull(requests.sub_program_id, ''), '-', '-')), ',',
        CRC32(concat('-', '-', ifnull(requests.initiative_id, ''), '-')), ',',
        CRC32(concat('-', '-', '-', ifnull(requests.sub_initiative_id, ''))))"
  end
  
  def self.allocation_hierarchy
    "group_concat(CRC32(concat(ifnull(if (funding_source_allocations.program_id is not null, funding_source_allocations.program_id, 
                  if(funding_source_allocations.sub_program_id is not null, (select program_id from sub_programs where id = funding_source_allocations.sub_program_id),
                    if(funding_source_allocations.initiative_id is not null, (select program_id from sub_programs where id = (select sub_program_id from initiatives where initiatives.id = funding_source_allocations.initiative_id)), 
                      if(funding_source_allocations.sub_initiative_id is not null, (select program_id from sub_programs where id = (select sub_program_id from initiatives where initiatives.id = (select initiative_id from sub_initiatives where sub_initiatives.id = funding_source_allocations.sub_initiative_id))), null)))), ifnull(request_funding_sources.program_id, '')), '-', '-', '-')),
                      ',',
          CRC32(concat('-',
          ifnull(if(funding_source_allocations.sub_program_id is not null, funding_source_allocations.sub_program_id,
          		    if(funding_source_allocations.initiative_id is not null, (select sub_program_id from initiatives where initiatives.id = funding_source_allocations.initiative_id),
                    if(funding_source_allocations.sub_initiative_id is not null, (select sub_program_id from initiatives where initiatives.id = (select initiative_id from sub_initiatives where sub_initiatives.id = funding_source_allocations.sub_initiative_id)), null))), ifnull(request_funding_sources.sub_program_id, '')), '-', '-')),
                      ',',
          CRC32(concat('-','-',
          ifnull(
            if(funding_source_allocations.initiative_id is not null, funding_source_allocations.initiative_id, 
                  if(funding_source_allocations.sub_initiative_id is not null, (select initiative_id from sub_initiatives where sub_initiatives.id = funding_source_allocations.sub_initiative_id), null)),
                  ifnull(request_funding_sources.initiative_id, '')
          ), '-')),
                      ',',
          CRC32(concat('-','-','-',ifnull(funding_source_allocations.sub_initiative_id, ifnull(request_funding_sources.sub_initiative_id, ''))))
          )
    "
  end
  
  # This allows us to take a "3-8-52-,3---,1-99-2-15" hierarchy string of prog/subprog/init/subinit and match it against the request
  def self.prepare_hierarchy search_with_attributes, name, val
    if val
      search_with_attributes[name] = []
      val = val.first if val.is_a?(Array)
      val.split(',').each do |tuple|
        prog_id, subprog_id, init_id, subinit_id = tuple.split('-')
        if !subinit_id.blank?
          prog_id = subprog_id = init_id = ''
        elsif !init_id.blank?
          prog_id = subprog_id = ''
        elsif !subprog_id.blank?
          prog_id = ''
        end
          
        if !prog_id.blank?
          program = Program.find prog_id rescue nil
          if program
            if program.children_programs && !program.children_programs.empty?
              program.children_programs.each do |child_program|
                search_with_attributes[name] << "#{child_program.id}---".to_crc32
              end
            else
              search_with_attributes[name] << "#{prog_id}-#{subprog_id}-#{init_id}-#{subinit_id}".to_crc32
            end
          end
        else
          search_with_attributes[name] << "#{prog_id}-#{subprog_id}-#{init_id}-#{subinit_id}".to_crc32 if tuple && tuple != '---'
        end
      end
    end
    search_with_attributes.delete(name) if search_with_attributes[name] && search_with_attributes[name].empty?
  end
  
end