module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      #
      # main_table: name of the table to add the FK to
      # fk_name: name of the foreign key
      # main_field: name of the field which points to the foreign key
      # fk_table: name of the table which contains the foreign key
      # fk_field: name of the field which has the foreign key
      def add_constraint main_table, fk_name, main_field, fk_table, fk_field, options={}
        execute "alter table #{main_table} add constraint #{fk_name} foreign key (#{main_field}) references #{fk_table}(#{fk_field})" unless adapter_name =~ /SQLite/i || Rails.env.test?
      end
      
      # main_table: name of table you want to remove the FK from
      # fk_name: name of FK you want to remove
      def remove_constraint main_table, fk_name, options={}
        execute "alter table #{main_table} DROP FOREIGN KEY #{fk_name}" unless adapter_name =~ /SQLite/i || Rails.env.test?
      end
      
      def add_long_text_column main_table, column_name, options={}
        if adapter_name =~ /mysql/i
          execute "ALTER TABLE #{main_table.to_s} ADD COLUMN #{column_name.to_s} longtext collate utf8_unicode_ci" 
        else
          add_column main_table, column_name, :text
        end
      end
      
      def current_time_function
        if adapter_name =~ /mysql/i
          "now()"
        else
          "null"
        end
      end
    end
  end
end