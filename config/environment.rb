# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
FluxxGrantRi::Application.initialize!

require 'thinking_sphinx/deltas/delayed_delta'
GrantRequest
RequestTransaction
Organization
User
RequestReport

if defined?(PhusionPassenger)
 PhusionPassenger.on_event(:starting_worker_process) do |forked|
   if forked
     ActiveRecord::Base.logger.debug "IN smart spawning mode, reestablishing connection to memcached"
     Rails.cache.instance_variable_get(:@data).reset if Rails.cache.class == ActiveSupport::Cache::MemCacheStore
   else
       ActiveRecord::Base.logger.debug "NOT in smart spawning mode, no need to reestablish our connection to memcached"
   end
 end
end
