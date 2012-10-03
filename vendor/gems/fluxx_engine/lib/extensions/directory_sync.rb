require 'rails/generators'

class DirectorySync < Rails::Generators::Base
  include Rails::Generators::Actions
  
  ALL_SYNCS = []
  
  def initialize paths
    @paths = paths
    ALL_SYNCS << self # Keep a reference to each that gets initialized so we can run it at will
    @options = {:force => true, :verbose => false}
  end
  
  def self.sync_all specific_path=nil
    ALL_SYNCS.each do |sync| 
      sync.copy_fluxx_public_files specific_path
    end
  end
  
  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end
  
  def copy_fluxx_public_files specific_path=nil
    self.destination_root=Rails.root
    @paths.each do |path_pair|
      source, dest = path_pair
      if specific_path
        if specific_path =~/^#{dest}/
          specific_file = specific_path.gsub /^#{dest}/, ''
          copy_file "#{source}/#{specific_file}", "public/#{specific_path}", :verbose => false, :force => true
        end
      else
        directory source, "public/#{dest}", :verbose => false, :force => true
      end
    end
  end
end
