# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dummy::Application.initialize!

require 'thinking_sphinx/deltas/delayed_delta'

FLUXX_CONFIGURATION = {}