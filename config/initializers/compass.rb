require 'compass'
require 'compass/app_integration/rails'
Compass::AppIntegration::Rails.initialize!
Sass::Plugin.add_template_location "#{File.dirname(__FILE__).to_s}../../app/stylesheets", "public/stylesheets/compiled/fluxx_grant_ri"
