# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
FluxxGrantRi::Application.initialize!

require 'thinking_sphinx/deltas/delayed_delta'
GrantRequest
RequestTransaction
Organization
User
RequestReport
