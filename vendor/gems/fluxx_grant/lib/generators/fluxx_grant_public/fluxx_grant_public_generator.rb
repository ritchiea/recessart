require 'rails/generators'
require 'rails/generators/migration'

class FluxxGrantPublicGenerator < Rails::Generators::Base
  include Rails::Generators::Actions

  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end

  def build_and_copy_fluxx_public_files
    public_dir = File.join(File.dirname(__FILE__), '../../../public')

    run "/bin/rm -f -r #{Rails.root}/public/fluxx_grant/javascripts"
    
    directory("#{public_dir}/fluxx_grant/javascripts", 'public/fluxx_grant/javascripts')
  end
end
