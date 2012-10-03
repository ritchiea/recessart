require 'rails/generators'
require 'rails/generators/migration'

class FluxxEnginePublicGenerator < Rails::Generators::Base
  include Rails::Generators::Actions

  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end

  def build_and_copy_fluxx_public_files
    public_dir = File.join(File.dirname(__FILE__), '../../../public')

    run "cd #{public_dir}/fluxx_engine && rake build"
    
    directory("#{public_dir}/fluxx_engine/dist", 'public/fluxx_engine/dist')
    directory("#{public_dir}/fluxx_engine/theme", 'public/fluxx_engine/theme')
  end
end
