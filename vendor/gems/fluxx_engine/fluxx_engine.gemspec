# -*- ruby -*-

Gem::Specification.new do |s|
  s.rubyforge_project = "fluxx_engine"
  s.name              = "fluxx_engine"
  s.version           = "0.0.21"
  s.authors           = ["Eric Hansen"]
  s.email             = ["eric@fluxxlabs.com"]
  s.homepage          = "http://fluxxlabs.com"

  s.license           = "GPLv2"
  s.summary           = %q{Fluxx Engine}
  s.description       = %q{Fluxx Engine}

  s.files             = `git ls-files`.split("\n")
  s.bindir            = "bin"
  s.executables       = `git ls-files bin`.split("\n").map{|filename| filename.gsub(/^bin\//, '')}
  s.test_files        = `git ls-files -- {test}/*`.split("\n")
  s.require_paths     = ["lib"]

  s.add_dependency 'rails', '3.0.3'
  s.add_dependency 'thin', '>= 1.2.7'
  s.add_dependency 'mysql'
  s.add_dependency "aasm", '2.2.0'
  s.add_dependency 'acts_as_audited_rails3', '>= 1.1.2'
  s.add_dependency 'haml', '>= 3'
  s.add_dependency 'sass'
  s.add_dependency 'formtastic', '= 1.1.0'
  s.add_dependency 'will_paginate', '~> 3.0.pre2'
  s.add_dependency 'jsmin', '>= 1.0.1'
  s.add_dependency 'thinking-sphinx', '>= 2.0.1'
  s.add_dependency "authlogic"
  s.add_dependency 'ruby-net-ldap'
  s.add_dependency 'paperclip'
  s.add_dependency 'liquid'
  s.add_dependency 'delocalize'
  s.add_dependency 'pdfkit'
  s.add_dependency 'writeexcel', '>= 0.6.1'
  s.add_dependency 'fastercsv', '>= 1.5.3'

  s.add_development_dependency 'capybara', '0.3.7'
  s.add_development_dependency 'machinist', '>= 1.0.6'
  s.add_development_dependency 'faker', '>= 0.3.1'
  s.add_development_dependency 'mocha', '>= 0.9'
  s.add_development_dependency 'rcov'
end
