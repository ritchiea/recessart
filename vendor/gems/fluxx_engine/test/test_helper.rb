# Configure Rails Environment
ENV["RAILS_ENV"] = "test"


require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require File.join(File.dirname(__FILE__), 'blueprint')

require "rails/test_help"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

def setup_multi
  add_multi_elements
  Musician.insta_multi
  Instrument.insta_multi
end

def add_multi_elements
  @instrument_group = MultiElementGroup.make :target_class_name => 'Instrument', :name => 'categories', :description => 'categories'
  @woodwind_value = MultiElementValue.make :description => 'woodwind', :value => 'woodwind', :multi_element_group => @instrument_group
  @brass_value = MultiElementValue.make :description => 'brass', :value => 'brass', :multi_element_group => @instrument_group
  @percussion_value = MultiElementValue.make :description => 'percussion', :value => 'percussion', :multi_element_group => @instrument_group
  @string_value = MultiElementValue.make :description => 'string', :value => 'string', :multi_element_group => @instrument_group
  
  
  @music_type_group = MultiElementGroup.make :target_class_name => 'Musician', :name => 'music_type', :description => 'music type'
  @blues_value = MultiElementValue.make :description => 'blues', :value => 'blues', :multi_element_group => @music_type_group
  @jazz_value = MultiElementValue.make :description => 'jazz', :value => 'jazz', :multi_element_group => @music_type_group
  @folk_value = MultiElementValue.make :description => 'folk', :value => 'blues', :multi_element_group => @music_type_group
  @opera_value = MultiElementValue.make :description => 'opera', :value => 'opera', :multi_element_group => @music_type_group
end

class SimpleFormat
  attr_accessor :csv
  attr_accessor :xls
  attr_accessor :json
  
  def initialize csv_param=nil, xls_param=nil, json_param=nil
    self.csv = csv_param
    self.xls = xls_param
    self.json = json_param
  end
  
  def csv?
    csv
  end
  def xls?
    xls
  end
end

include FluxxEngineTestHelper
# Swap out the thinking sphinx sphinx interface with actual SQL
module ThinkingSphinx
  module SearchMethods
    module ClassMethods
    
      def search_for_ids(*args)
        paged_objects = search *args
        raw_ids = paged_objects.map &:id
        WillPaginate::Collection.create paged_objects.current_page, paged_objects.per_page, paged_objects.total_pages do |pager|
          pager.replace raw_ids
        end
      end
    
      def search(*args)
        self.paginate(:page => 1)
      end
    end
  end
end

def current_user
  @current_user unless @current_user == false
end

# Store the given user id in the session.
def current_user=(new_user)
  @current_user = new_user || false
end

def add_perms user
  [ClientStore, Instrument, Musician, MusicianInstrument, Orchestra, TotalDummyReport].each do |klass|
    user.has_permission! 'listview', klass
    user.has_permission! 'view', klass
    user.has_permission! 'create', klass
    user.has_permission! 'update', klass
    user.has_permission! 'delete', klass
  end
end

def login_as user
  @controller.current_user = user
  add_perms user
end

class ActionController::Base
  attr_accessor :current_user
end
