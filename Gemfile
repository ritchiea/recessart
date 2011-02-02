dev_local = ENV['DEV_LOCAL']

source "http://gemcutter.org"

gem 'rails', '3.0.3'
  
gem "sqlite3-ruby", :require => "sqlite3"
gem "will_paginate", "~> 3.0.pre2"
gem "capybara", "0.3.7"
gem 'mysql'
gem 'haml', '>= 3'
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
gem 'capistrano'
gem "exception_notification", :git => "git://github.com/rails/exception_notification", :require => 'exception_notifier'

cur_dir = File.dirname(__FILE__)
if File.exist?("#{cur_dir}/../fluxx_grant")
  require "#{cur_dir}/../fluxx_grant/lib/extensions/gem_handler.rb"
elsif File.exist?("#{cur_dir}/fluxx_grant")
  require "#{cur_dir}/fluxx_grant/lib/extensions/gem_handler.rb"
end
gem_versions = {:fluxx_engine => '>= 0.0.7', :fluxx_crm => '>= 0.0.4', :fluxx_grant => '>= 0.0.1'}
self.instance_exec [dev_local, cur_dir, gem_versions], &GemHandler.dependent_gems_block

if RUBY_VERSION < '1.9'
  gem "ruby-debug", ">= 0.10.3"
end
