# If you are migrating from a restful_authentication style DB, you can do this:
REST_AUTH_SITE_KEY         = '0c66496cd33bf88117bd2a583ad213e0de755bb3'
Authlogic::CryptoProviders::Sha1.instance_variable_set '@stretches', 10
