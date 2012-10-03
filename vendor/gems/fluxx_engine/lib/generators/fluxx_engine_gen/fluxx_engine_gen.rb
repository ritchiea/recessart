require 'rails/generators'

class FluxxEngineGen < Rails::Generators::Base
  include Rails::Generators::Actions
  
  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end
  
  argument :genaction, :type => :string, :desc => "The action to perform"
  desc "Allows user to generate either a [migration|model|controller]"

  argument :genresultname, :type => :string, :desc => "The name to be applied for this action"
  desc "Specify the nmae of the new [migration|model|controller]"

  def generate_scaffold
    if genaction == 'scaffold'
      perform_create_model genresultname
      perform_create_controller genresultname
    end
  end
  
  def generate_migration
    if genaction == 'migration'
      perform_create_migration genresultname
    end
  end
  
  def generate_model
    if genaction == 'model'
      perform_create_model genresultname
    end
  end
  
  def generate_controller
    if genaction == 'controller'
      perform_create_controller genresultname
    end
  end
  
  def migration_class_name
    @migration_name.titlecase.gsub ' ', '' if @migration_name
  end

  def model_class_plural_table_name
    @model_singular_name.pluralize if @model_singular_name
  end

  def model_class_singular_table_name
    @model_singular_name if @model_singular_name
  end

  def model_class_name
    @model_singular_name.titlecase.gsub ' ', '' if @model_singular_name
  end
  
  def controller_class_plural_table_name
    @controller_singular_name.pluralize if @controller_singular_name
  end

  def controller_class_singular_table_name
    @controller_singular_name if @controller_singular_name
  end

  def controller_class_name
    @controller_singular_name.pluralize.titlecase.gsub ' ', '' if @controller_singular_name
  end

  def controller_class_singular_name
    @controller_singular_name.titlecase.gsub ' ', '' if @controller_singular_name
  end

  def migrate_up
    @migrate_up
  end
  
  def migrate_down
    @migrate_down
  end
  
  private
  
  def perform_create_model model_name
    @model_singular_name = model_name.underscore.downcase.singularize
    model_lib_dir_name = 'lib/extensions/models'
    app_model_dir_name = 'app/models'
    unit_test_dir_name = 'test/unit'
    blueprint_file_name = 'test/blueprint.rb'
    if File.exist?(model_lib_dir_name) && File.exist?(app_model_dir_name) && File.exist?(unit_test_dir_name) && File.exist?(blueprint_file_name)
      model_filename = model_name.underscore 
      # Create the dummy model first
      template "dummy_model_template.rb", "#{app_model_dir_name}/#{model_filename}.rb"

      # Create the lib model
      template "lib_model_template.rb", "#{model_lib_dir_name}/fluxx_#{model_filename}.rb"

      # Add the model to the blueprint file
      open(blueprint_file_name, 'a') { |f|
        f << "
#{model_class_name}.blueprint do
end
"
      }
      say_status "insert", "Added a blueprint for #{model_class_name} to #{blueprint_file_name}"

      # Add a test file
      template "model_test_template.rb", "#{unit_test_dir_name}/#{model_filename}_test.rb"

      # Add a new migration
      @migrate_up = "    create_table \"#{@model_singular_name.pluralize}\", :force => true do |t|
    t.timestamps
    t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
  end

  add_constraint '#{@model_singular_name.pluralize}', '#{@model_singular_name.pluralize}_created_by_id', 'created_by_id', 'users', 'id'
  add_constraint '#{@model_singular_name.pluralize}', '#{@model_singular_name.pluralize}_updated_by_id', 'updated_by_id', 'users', 'id'"
      @migrate_down = "drop_table \"#{@model_singular_name.pluralize}\""
      perform_create_migration "create_#{model_name}"
    else
      say_status "warn", "Cannot find #{model_lib_dir_name} or #{app_model_dir_name} or #{unit_test_dir_name} or #{blueprint_file_name}, you must be in the home directory of the gem you are adding to.  If you are, making sure that these directories exist."
    end
  end
  
  def perform_create_controller controller_name
    @controller_singular_name = controller_name.underscore.downcase.singularize
    controller_lib_dir_name = 'lib/extensions/controllers'
    app_controller_dir_name = 'app/controllers'
    app_views_dir_name = 'app/views'
    functional_test_dir_name = 'test/functional'
    if File.exist?(controller_lib_dir_name) && File.exist?(app_controller_dir_name) && File.exist?(functional_test_dir_name) && File.exist?(app_views_dir_name)
      # Create the dummy controller first
      template "dummy_controller_template.rb", "#{app_controller_dir_name}/#{controller_class_plural_table_name}_controller.rb"

      # Create the lib controller
      template "lib_controller_template.rb", "#{controller_lib_dir_name}/fluxx_#{controller_class_plural_table_name}_controller.rb"
      
      # Add a test functional file
      template "controller_test_template.rb", "#{functional_test_dir_name}/#{controller_class_plural_table_name}_controller_test.rb"
      
      # add a route
      route "resources :#{@controller_singular_name.pluralize}"
      
      # create _form, _show and _list haml templates
      empty_directory "#{app_views_dir_name}/#{controller_class_plural_table_name}"
      template "controller_list_template.html.haml", "#{app_views_dir_name}/#{controller_class_plural_table_name}/_#{controller_class_singular_table_name}_list.html.haml"
      template "controller_form_template.html.haml", "#{app_views_dir_name}/#{controller_class_plural_table_name}/_#{controller_class_singular_table_name}_form.html.haml"
      template "controller_show_template.html.haml", "#{app_views_dir_name}/#{controller_class_plural_table_name}/_#{controller_class_singular_table_name}_show.html.haml"
    else
      say_status "warn", "Cannot find #{controller_lib_dir_name} or #{app_controller_dir_name} or #{functional_test_dir_name} or #{app_views_dir_name}, you must be in the home directory of the gem you are adding to.  If you are, making sure that these directories exist."
    end
  end
  
  def perform_create_migration migration_name
    @migrate_up ||= ''
    @migrate_down ||= ''
    migration_name = migration_name.underscore
    # Try to find the migration script for this project
    search_string = "_migration_generator.rb"
    generators_path = "lib/generators/**/*#{search_string}"
    possible_files = Dir.glob generators_path
    if possible_files.size == 1 && !File.basename(possible_files.first).blank?
      migration_file = possible_files.first
      basename = File.basename migration_file
      directory = File.dirname migration_file
      class_prefix = basename.split(search_string).first
      say_status "insert", "adding a migration #{migration_name} to #{migration_file}"
      @migration_name = "#{class_prefix}_#{migration_name}"
      klass_name = basename.gsub(".rb", "").titlecase.gsub(' ', '')
      inject_into_class migration_file, klass_name, "  def #{migration_name}
    handle_migration '#{migration_name}.rb', 'db/migrate/#{@migration_name}.rb'
    sleep 1
  end

", {}
      template "migrate_template.rb", "#{directory}/templates/#{migration_name}.rb"
    elsif possible_files.size > 1
      say_status "warn", "Cannot determine which migration file to use out of #{possible_files.inspect}"
    else
      say_status "warn", "Could not find a matching file; looking for #{generators_path}"
    end
  end
end