class FluxxGrantSwitchAroundProgramInitiativeEtc < ActiveRecord::Migration
  def self.up
    # get rid of referential integrity
    unless adapter_name =~ /SQLite/i
      execute "ALTER TABLE request_funding_sources DROP FOREIGN KEY rfs_sub_initiative_id"
      execute "ALTER TABLE request_funding_sources DROP FOREIGN KEY request_funding_sources_funding_source_id"
      execute "ALTER TABLE request_funding_sources DROP FOREIGN KEY request_funding_sources_initiative_id"
      execute "ALTER TABLE request_funding_sources DROP FOREIGN KEY request_funding_sources_program_id"
      execute "ALTER TABLE request_funding_sources DROP FOREIGN KEY request_funding_sources_request_id"
      execute "ALTER TABLE request_funding_sources DROP FOREIGN KEY rfs_board_authority_id"
      execute "ALTER TABLE request_funding_sources DROP FOREIGN KEY rfs_sub_program_id"
      execute "ALTER TABLE requests DROP FOREIGN KEY requests_program_id"
      execute "ALTER TABLE requests DROP FOREIGN KEY requests_initiative_id"
      execute "ALTER TABLE initiatives DROP FOREIGN KEY initiatives_program_id"
      execute "ALTER TABLE sub_initiatives DROP FOREIGN KEY sub_initiative_sub_program_id"
      execute "ALTER TABLE sub_programs DROP FOREIGN KEY sub_program_initiative_id"
    end
    
    # requests; initiative_id should be renamed to sub_program_id
    execute "ALTER TABLE requests change column initiative_id sub_program_id int(11) DEFAULT NULL"
    
    # request_funding_sources nothing changes but referential integrity
    
    # rename sub_programs and initiatives
    execute "RENAME TABLE sub_programs to tmp_table"
    execute "RENAME TABLE initiatives to sub_programs"
    execute "RENAME TABLE tmp_table to initiatives"
    
    # change initiatives column initiative_id to sub_program_id 
    execute "ALTER TABLE initiatives change column initiative_id sub_program_id  int(11) DEFAULT NULL"
    # change sub_initiatives column sub_program_id to initiative_id
    execute "ALTER TABLE sub_initiatives change column sub_program_id initiative_id  int(11) DEFAULT NULL"
    
    # resume referential integrity
    unless adapter_name =~ /SQLite/i
      execute "ALTER TABLE sub_programs ADD CONSTRAINT `sub_programs_program_id` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`)"
      execute "ALTER TABLE initiatives ADD CONSTRAINT `initiative_sub_program_id` FOREIGN KEY (`sub_program_id`) REFERENCES `sub_programs` (`id`)"
      execute "ALTER TABLE sub_initiatives ADD CONSTRAINT `sub_initiative_initiative_id` FOREIGN KEY (`initiative_id`) REFERENCES `initiatives` (`id`)"
      execute "ALTER TABLE requests ADD CONSTRAINT `requests_program_id` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`)"
      execute "ALTER TABLE requests ADD CONSTRAINT `requests_sub_program_id` FOREIGN KEY (`sub_program_id`) REFERENCES `sub_programs` (`id`)"
      execute "ALTER TABLE request_funding_sources ADD CONSTRAINT `rfs_sub_initiative_id` FOREIGN KEY (`sub_initiative_id`) REFERENCES `sub_initiatives` (`id`)"
      execute "ALTER TABLE request_funding_sources ADD CONSTRAINT `request_funding_sources_funding_source_id` FOREIGN KEY (`funding_source_id`) REFERENCES `funding_sources` (`id`)"
      execute "ALTER TABLE request_funding_sources ADD CONSTRAINT `request_funding_sources_initiative_id` FOREIGN KEY (`initiative_id`) REFERENCES `initiatives` (`id`)"
      execute "ALTER TABLE request_funding_sources ADD CONSTRAINT `request_funding_sources_program_id` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`)"
      execute "ALTER TABLE request_funding_sources ADD CONSTRAINT `request_funding_sources_request_id` FOREIGN KEY (`request_id`) REFERENCES `requests` (`id`)"
      execute "ALTER TABLE request_funding_sources ADD CONSTRAINT `rfs_board_authority_id` FOREIGN KEY (`board_authority_id`) REFERENCES `multi_element_values` (`id`)"
      execute "ALTER TABLE request_funding_sources ADD CONSTRAINT `rfs_sub_program_id` FOREIGN KEY (`sub_program_id`) REFERENCES `sub_programs` (`id`)"
    end
  end

  def self.down
    
  end
end