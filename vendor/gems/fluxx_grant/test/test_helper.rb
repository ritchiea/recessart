# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require File.join(File.dirname(__FILE__), 'blueprint')
require "rails/test_help"

require 'mocha'

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


include FluxxGrantTestHelper
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def setup_fixtures
    TestHelper.load_megs
    super
  end

  setup :clear_out_blueprint_attributes

  def clear_out_blueprint_attributes
    TestHelper.clear_blueprint
  end
end


# Do not audit log during tests
module CollectiveIdea #:nodoc:
  module Acts #:nodoc:
    module Audited #:nodoc:
      module InstanceMethods
        private
        def write_audit(attrs)
          # Do nothing during tests
          # self.audits.create attrs if auditing_enabled
        end
      end
    end
  end
end

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
