# -*- ruby -*-

begin
  require 'bundler/gem_tasks'
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "Run `gem install bunlder` to install 'bundler' gem."
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs += ['lib', 'test']
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

require 'rcov/rcovtask'
Rcov::RcovTask.new(:rcov) do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.rcov_opts << "--exclude \"test/*,gems/*,/Library/Ruby/*,config/*\" --rails" 
end

task :default => :test
