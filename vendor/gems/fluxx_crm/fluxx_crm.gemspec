# -*- ruby -*-

Gem::Specification.new do |s|
  s.rubyforge_project = "fluxx_crm"
  s.name              = "fluxx_crm"
  s.version           = "0.0.21"
  s.authors           = ["Eric Hansen"]
  s.email             = ["eric@fluxxlabs.com"]
  s.homepage          = "http://fluxxlabs.com"

  s.license           = "GPLv2"
  s.summary           = %q{Fluxx CRM}
  s.description       = %q{Fluxx CRM}

  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test}/*`.split("\n")
  s.require_paths     = ["lib"]

  s.add_development_dependency 'capybara', '0.3.7'
  s.add_development_dependency 'machinist', '>= 1.0.6'
  s.add_development_dependency 'faker', '>= 0.3.1'
  s.add_development_dependency 'mocha', '>= 0.9'
  s.add_development_dependency 'rcov'
end
