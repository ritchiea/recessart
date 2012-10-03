# -*- ruby -*-

Gem::Specification.new do |s|
  s.rubyforge_project = "fluxx_grant"
  s.name              = "fluxx_grant"
  s.version           = "0.0.17"
  s.authors           = ["Eric Hansen"]
  s.email             = ["eric@fluxxlabs.com"]
  s.homepage          = "http://fluxxlabs.com"

  s.license           = "GPLv2"
  s.summary           = %q{Fluxx Grant Core}
  s.description       = %q{Fluxx Grant Code}

  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test}/*`.split("\n")
  s.require_paths     = ["lib"]

  s.add_dependency "delayed_job"
  s.add_dependency "ts-delayed-delta", ">= 1.1.0"
  s.add_dependency "httpi"
  s.add_dependency "crack"
  s.add_dependency 'memcache-client', '>= 1.8.5'
  s.add_dependency 'capistrano'
  s.add_dependency 'aws-s3'
  s.add_dependency 'capistrano-ext'
  s.add_dependency 'hoptoad_notifier'

  s.add_development_dependency 'capybara', '0.3.7'
  s.add_development_dependency 'machinist', '>= 1.0.6'
  s.add_development_dependency 'faker', '>= 0.3.1'
  s.add_development_dependency 'mocha', '>= 0.9'
  s.add_development_dependency 'rcov'
end
