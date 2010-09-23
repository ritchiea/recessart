# This file is used by Rack-based servers to start the application.

# This file is used by Rack-based servers to start the application.
module Rack
  class FluxxBuilder
    def initialize app
      @app = app
      @build_dir = 'public/fluxx_engine'
      @path_prefix = '/fluxx_engine/'
    end
    def call env
      path = Utils.unescape(env["PATH_INFO"])
      if path.match('\.css$')
        file = path.gsub(/^#{@path_prefix}/, '')
        $stderr.puts ">>> BUILDING #{file}"
        `cd #{@build_dir} && rake build:css[#{file}]`
      elsif path.match('\.js$')
        `cd #{@build_dir} && rake build:js`
      end
begin
      @app.call env
rescue Exception => e
  p "Rack stack trace: #{e.backtrace}"
end
    end
  end
end

is_ui_dev = ENV['FLUXX_UI_DEV'].to_i == 1 ? true : false
puts "FLUXX_UI_DEV = #{is_ui_dev}"
use Rack::FluxxBuilder if is_ui_dev
require ::File.expand_path('../config/environment',  __FILE__)

begin
  run FluxxGrantRi::Application
rescue Exception => e
  p "Rack stack trace: #{e.backtrace}"
end
