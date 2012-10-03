module ActionView
  class Resolver

  private

#   Allow template caching to be turned off while config.cache_classes is set to true.
    def caching?
      if defined?(DISABLE_TEMPLATE_CACHE) && DISABLE_TEMPLATE_CACHE
        false
      else
        @caching ||= !defined?(Rails.application) || Rails.application.config.cache_classes
      end
    end
  end
end

