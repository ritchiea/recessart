# -*- ruby -*-

begin
  require 'bundler/gem_tasks'
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "Run `gem install bundler` to install 'bundler' gem."
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

#require 'rdoc/task'
#Rake::RDocTask.new(:rdoc) do |rdoc|
#  rdoc.rdoc_dir = 'rdoc'
#  rdoc.title = 'FluxxEngine'
#  rdoc.options << '--line-numbers' << '--inline-source'
#  rdoc.rdoc_files.include('README.rdoc')
#  rdoc.rdoc_files.include('lib/**/*.rb')
#end
