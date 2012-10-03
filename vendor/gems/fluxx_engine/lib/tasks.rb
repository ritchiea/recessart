namespace :fluxx_engine do
  desc "force a recompile of all the SASS"
  task :recompile_all_sass => :environment do
    Sass::Plugin.force_update_stylesheets
  end
end