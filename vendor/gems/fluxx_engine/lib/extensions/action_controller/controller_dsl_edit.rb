class ActionController::ControllerDslEdit < ActionController::ControllerDsl
  # add a class to the form element
  attr_accessor :form_class
  # specify the URL for the form
  attr_accessor :form_url
  
  def perform_edit params, model=nil, fluxx_current_user=nil
    model = load_existing_model params, model

    if editable? model, fluxx_current_user
      add_lock model, fluxx_current_user
    end
    model
  end
end