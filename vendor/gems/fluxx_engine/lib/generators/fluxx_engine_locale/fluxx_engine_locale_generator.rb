require 'rails/generators'

class FluxxEngineLocaleGenerator < Rails::Generators::Base
  include Rails::Generators::Actions

  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end

  def add_fluxx_localize_path
    environment "config.i18n.load_path << Dir[File.join(Rails.root, 'config', 'fluxx_locales', '*.{rb,yml}')].first"
  end

  def copy_fluxx_localization_files
    copy_file 'en.yml', 'config/fluxx_locales/en.yml'
  end
  
  # TODO ESH: add mime types
end
