class ActionController::ControllerDslCreate < ActionController::ControllerDsl
# GETTERS/SETTERS stored here:
  attr_accessor :link_to_method
  # A message to send back after a successful completion of the creation
  attr_accessor :render_inline
  # A redirect to issue after a successful completion of the creation
  attr_accessor :redirect
  # add a class to the form element
  attr_accessor :form_class
  # specify the URL for the form
  attr_accessor :form_url

# ACTUALLY USED IN THIS CLASS
  # A call to make after the save occurs
  attr_accessor :post_save_call

  def perform_create params, model, fluxx_current_user=nil
    post_save_call_proc = self.post_save_call || lambda{|fluxx_current_user, model, params|true}
    
    if model.respond_to?(:created_by_id) && fluxx_current_user
      model.created_by_id = fluxx_current_user.id
    end
    if model.respond_to?(:updated_by_id) && fluxx_current_user
      model.updated_by_id = fluxx_current_user.id
    end
    
    model.save && post_save_call_proc.call(fluxx_current_user, model, params)
  end
end