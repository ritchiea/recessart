class ActionController::ControllerDslNew < ActionController::ControllerDsl
  # add a class to the form element
  attr_accessor :form_class
  # specify the URL for the form
  attr_accessor :form_url
end