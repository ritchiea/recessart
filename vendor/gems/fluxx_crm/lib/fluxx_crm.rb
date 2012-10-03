require "rails"
require "fluxx_engine"

# Some classes need to be required before or after; put those in these lists
CRM_EXTENSION_CLASSES_TO_PRELOAD = []
CRM_EXTENSION_CLASSES_TO_POSTLOAD = []

CRM_EXTENSION_CLASSES_TO_NOT_AUTOLOAD = CRM_EXTENSION_CLASSES_TO_PRELOAD + CRM_EXTENSION_CLASSES_TO_POSTLOAD
CRM_EXTENSION_CLASSES_TO_PRELOAD.each do |filename|
  require filename
end
Dir.glob("#{File.dirname(__FILE__).to_s}/extensions/**/*.rb").map{|filename| filename.gsub /\.rb$/, ''}.
  reject{|filename| CRM_EXTENSION_CLASSES_TO_NOT_AUTOLOAD.include?(filename) }.each {|filename| require filename }
CRM_EXTENSION_CLASSES_TO_POSTLOAD.each do |filename|
  require filename
end

Dir.glob("#{File.dirname(__FILE__).to_s}/fluxx_crm/**/*.rb").each do |fluxx_crm|
  require fluxx_crm.gsub /\.rb$/, ''
end

ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__) + 
"/../app/helpers"
  Dir[File.dirname(__FILE__) + "/../app/helpers/**/*_helper.rb"].each do 
|file|
      ActionController::Base.helper "#{File.basename(file,'.rb').camelize}".constantize
  end

public_dir = File.join(File.dirname(__FILE__), '../public')
DirectorySync.new [
  ["#{public_dir}/images", '/images/fluxx_crm'],
  ["#{public_dir}/javascripts", '/javascripts/fluxx_crm'],
  ["#{public_dir}/stylesheets", '/stylesheets/fluxx_crm'],
]  
