# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
FluxxGrantRi::Application.initialize!

require 'thinking_sphinx/deltas/delayed_delta'

FLUXX_CONFIGURATION = {:grantor_name => 'Foundation', :show_printable_button => true, :show_pdf_button => true}

Request rescue nil
FipRequest rescue nil
GrantRequest rescue nil
Organization rescue nil
User rescue nil
RequestTransaction rescue nil
RequestReport rescue nil
Project rescue nil

if defined?(PhusionPassenger)
 PhusionPassenger.on_event(:starting_worker_process) do |forked|
   if forked
     ActiveRecord::Base.logger.debug "IN smart spawning mode, reestablishing connection to memcached"
     if defined?(SESSION_CACHE) && SESSION_CACHE.instance_of?(MemCache)
       SESSION_CACHE.reset 
       ActiveRecord::Base.logger.debug "reset session cache"
     end
     if Rails.cache.class == ActiveSupport::Cache::MemCacheStore
       Rails.cache.instance_variable_get(:@data).reset 
       ActiveRecord::Base.logger.debug "reset rails cache"
     end
   else
       ActiveRecord::Base.logger.debug "NOT in smart spawning mode, no need to reestablish our connection to memcached"
   end
 end
end
