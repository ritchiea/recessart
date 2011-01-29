class DropToDoProjectListType < ActiveRecord::Migration
  def self.up
    execute "delete from multi_element_values where multi_element_group_id = (select id from multi_element_groups where description = 'ListType' and target_class_name = 'ProjectList') and value = 'To-Do'"
  end

  def self.down
  end
end
