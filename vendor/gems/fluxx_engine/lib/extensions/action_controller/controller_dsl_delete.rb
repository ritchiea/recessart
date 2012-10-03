class ActionController::ControllerDslDelete < ActionController::ControllerDsl
  # A redirect to issue after a successful completion of the deletion
  attr_accessor :redirect
  
  def perform_delete params, model, fluxx_current_user=nil
    model.safe_delete(fluxx_current_user) if model
    model
  end
end