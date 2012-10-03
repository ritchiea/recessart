module Rack
  class FluxxBuilder
    def initialize app
      @app = app
      if defined?(FORCE_UPDATE_SASS) && FORCE_UPDATE_SASS
        # WARNING: this may cause problems if you're running with passenger phusion
        # p "beginning to force update of SASS stylesheets #{Time.now.inspect}"
        Sass::Plugin.force_update_stylesheets
        # p "after forcing update of SASS stylesheets #{Time.now.inspect}"
      else
        Sass::Plugin.update_stylesheets
      end
      @skip_fluxx_builder = defined?(SKIP_FLUXX_BUILDER) ? SKIP_FLUXX_BUILDER : true
      DirectorySync.sync_all
    end
    def call env
      unless @skip_fluxx_builder
        path = Utils.unescape(env["PATH_INFO"])
        t1 = Time.now
        if path.match('\.css$')
          Sass::Plugin.update_stylesheets
        elsif path.match('\.js$') || path.match('\.jpg$') || path.match('\.gif$') || path.match('\.png$') || path.match('\.svg$') || path.match('\.ttf$') || path.match('\.woff$') || path.match('\.eot$') || path.match('\.svg$')
          DirectorySync.sync_all path
        end
        t2 = Time.now
      end
      @app.call env
    end
  end
end