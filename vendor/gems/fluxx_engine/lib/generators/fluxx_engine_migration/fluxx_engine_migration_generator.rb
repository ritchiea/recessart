require 'rails/generators'
require 'rails/generators/migration'

class FluxxEngineMigrationGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end

  # Implement the required interface for Rails::Generators::Migration.
  # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
  def self.next_migration_number(dirname) #:nodoc:
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def create_realtime_updates
    handle_migration 'realtime_updates.rb', 'db/migrate/fluxx_engine_create_realtime_updates_table.rb'
    sleep 1
  end
  
  def create_multi_element_groups
    handle_migration 'create_multi_element_groups.rb', 'db/migrate/fluxx_engine_create_multi_element_groups.rb'
    handle_migration 'create_multi_element_values.rb', 'db/migrate/fluxx_engine_create_multi_element_values.rb'
    handle_migration 'create_multi_element_choices.rb', 'db/migrate/fluxx_engine_create_multi_element_choices.rb'
    handle_migration 'create_client_stores.rb', 'db/migrate/fluxx_engine_create_client_stores.rb'
  end
  
  private
  def handle_migration name, filename
    begin
      migration_template name, filename
      sleep 1
    rescue Exception => e
      p e.to_s
    end
  end
end
