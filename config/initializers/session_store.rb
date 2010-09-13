# Be sure to restart your server when you modify this file.

# FluxxGrantRi::Application.config.session_store :cookie_store, :key => '_fluxx_grant_ri_session'
# ActiveSupport::Cache.lookup_store :mem_cache_store, MEMCACHE_SERVER
# config.session_store :memcache_server => MEMCACHE_SERVER

FluxxGrantRi::Application.config.session_store :mem_cache_store, :memcache_server => MEMCACHE_SERVER
ActiveSupport::Cache.lookup_store :mem_cache_store, MEMCACHE_SERVER

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# FluxxGrantRi::Application.config.session_store :active_record_store
