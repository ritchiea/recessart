dev_local = ENV['DEV_LOCAL']

source "http://gemcutter.org"

gem 'rails', '3.0.3'
  
gem "sqlite3-ruby", :require => "sqlite3"
gem "will_paginate", "~> 3.0.pre2"
gem "capybara", "0.3.7"
gem 'mysql'
gem 'haml', '>= 3'
#gem 'thinking-sphinx', '2.0.1', :require => 'thinking_sphinx'
gem "thinking-sphinx", :git => "http://github.com/freelancing-god/thinking-sphinx.git", :branch => "rails3", :require => 'thinking_sphinx'
gem 'paperclip'
# gem 'devise', '1.1.2'

gem "authlogic"
gem 'machinist', '>=1.0.6'
gem 'faker', '>=0.3.1'
gem 'formtastic', '~> 1.1.0'
gem 'jsmin', '>= 1.0.1'
gem 'memcache-client', '>= 1.8.5'
# gem 'delayed_job', '>=2.1.0'
gem 'delayed_job', :git => 'git://github.com/collectiveidea/delayed_job.git'
gem 'ts-delayed-delta', '>=1.1.0'
gem 'liquid'

gem "aasm", '2.2.0'
gem 'acts_as_audited_rails3', '>=1.1.2'
if RUBY_VERSION < '1.9'
  gem 'fastercsv', '>= 1.5.3'
end
gem 'thin', '>= 1.2.7'
gem 'rcov'
gem 'compass'
gem 'exception_notification'
gem 'capistrano'


if dev_local 
  p "Installing dependent fluxx gems to point to local paths.  Be sure you install fluxx_engine, fluxx_crm and fluxx_grant in the same directory as the reference implementation."
  gem "fluxx_engine", '>= 0.0.7', :path => "../fluxx_engine"
  gem "fluxx_crm", '>= 0.0.4', :path => "../fluxx_crm", :require => 'fluxx_crm'
  gem "fluxx_grant", '>= 0.0.1', :path => "../fluxx_grant", :require => 'fluxx_grant'
else
  p "Installing dependent fluxx gems."
  gem "fluxx_engine", '>= 0.0.6'
  gem "fluxx_crm", '>= 0.0.4', :require => 'fluxx_crm'
  gem "fluxx_grant", '>= 0.0.1', :require => 'fluxx_grant'
end

if RUBY_VERSION < '1.9'
  gem "ruby-debug", ">= 0.10.3"
end
