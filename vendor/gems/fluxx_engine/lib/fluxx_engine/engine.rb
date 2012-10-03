require "rails"
require "action_controller"
require "active_record"
require "logger"

unless defined?(FLUXX_LOGGER)
  FLUXX_LOGGER = Logger.new(STDERR)
  FLUXX_LOGGER.formatter = proc { |severity, time, prog, msg| 
    "[#{time.strftime("%Y-%m-%d %H:%M:%S")}] #{severity}  #{msg}\n" 
  }
end

module Fluxx
  def self.logger=(logger)
    @logger = logger
  end
  def self.logger
    @logger ||= FLUXX_LOGGER
  end
  def self.config key_sought, type = :application
    if defined?(FluxxClient)
      FluxxClient.config key_sought, type
    else
      FLUXX_CONFIGURATION[:legacy_admin] = true unless FLUXX_CONFIGURATION[:legacy_admin] == false
      config = {:application.to_sym => FLUXX_CONFIGURATION.each{|key, val| FLUXX_CONFIGURATION[key] = (val == true ? "1" : "0") if (val == true || val == false)}, :charity_check => {:username => defined?(CHARITY_CHECK_USERNAME) ? CHARITY_CHECK_USERNAME : "", :password.to_s => defined?(CHARITY_CHECK_PASSWORD) ? CHARITY_CHECK_PASSWORD : "", :enabled => (defined?(CHARITY_CHECK_USERNAME) && !CHARITY_CHECK_USERNAME.empty?) ? "1" : "0"}, :foundation_center => {:enabled => "1"}}
      config[type.to_sym][key_sought.to_sym]
    end
  end
end

module FluxxEngine
  class Engine < Rails::Engine
    config.i18n.load_path += Dir["#{File.dirname(__FILE__).to_s}/../../config/fluxx_locales/*.{rb,yml}"]
    initializer 'fluxx_engine.add_compass_hooks', :after=> :disable_dependency_loading do |app|
      Fluxx.logger.debug "Loaded FluxxEngine"
      Sass::Plugin.add_template_location "#{File.dirname(__FILE__).to_s}/../../app/stylesheets", "public/stylesheets/compiled/fluxx_engine"
    end
    rake_tasks do
      load File.expand_path('../../tasks.rb', __FILE__)
    end
  end
end
