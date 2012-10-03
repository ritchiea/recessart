require "formtastic" 
require "will_paginate" 
require "acts_as_audited_rails3"
require "pdfkit"
require "haml"
require "thinking_sphinx"
require "authlogic"
require "aasm"
require "paperclip"
require "liquid"
require "delocalize"
require "writeexcel"

# Some classes need to be required before or after; put those in these lists
EXTENSION_CLASSES_TO_PRELOAD = ["#{File.dirname(__FILE__).to_s}/extensions/action_controller/controller_dsl", "#{File.dirname(__FILE__).to_s}/extensions/active_record/model_dsl", "#{File.dirname(__FILE__).to_s}/extensions/blob_struct"]
EXTENSION_CLASSES_TO_POSTLOAD = ["#{File.dirname(__FILE__).to_s}/extensions/action_controller/base", "#{File.dirname(__FILE__).to_s}/extensions/active_record/base"]

EXTENSION_CLASSES_TO_NOT_AUTOLOAD = EXTENSION_CLASSES_TO_PRELOAD + EXTENSION_CLASSES_TO_POSTLOAD
EXTENSION_CLASSES_TO_PRELOAD.each do |filename|
  require filename
end
Dir.glob("#{File.dirname(__FILE__).to_s}/extensions/**/*.rb").map{|filename| filename.gsub /\.rb$/, ''}.
  reject{|filename| EXTENSION_CLASSES_TO_NOT_AUTOLOAD.include?(filename) }.each {|filename| require filename }
EXTENSION_CLASSES_TO_POSTLOAD.each do |filename|
  require filename
end

Dir.glob("#{File.dirname(__FILE__).to_s}/fluxx_engine/**/*.rb").each do |fluxx_engine_rb|
  require fluxx_engine_rb.gsub /\.rb$/, ''
end

ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__) + 
"/../app/helpers"
  Dir[File.dirname(__FILE__) + "/../app/helpers/**/*_helper.rb"].each do 
|file|
      ActionController::Base.helper "#{File.basename(file,'.rb').camelize}".constantize
  end

public_dir = File.join(File.dirname(__FILE__), '../public')
DirectorySync.new [
  ["#{public_dir}/images", '/images/fluxx_engine'],
  ["#{public_dir}/javascripts", '/javascripts/fluxx_engine'],
  ["#{public_dir}/stylesheets", '/stylesheets/fluxx_engine'],
]
