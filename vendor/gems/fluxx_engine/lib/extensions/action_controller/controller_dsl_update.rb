class ActionController::ControllerDslUpdate < ActionController::ControllerDsl
  SKIP_VALIDATION_CONSTANT = "@skip_validation_for_this_model"
  def self.skip_validation_constant
    SKIP_VALIDATION_CONSTANT
  end
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
  
  def populate_model params, model, fluxx_current_user=nil
    if editable?(model, fluxx_current_user)
      modified_by_map = {}
      if model.respond_to?(:updated_by_id) && fluxx_current_user
        modified_by_map[:updated_by_id] = fluxx_current_user.id
      end
      model.attributes = modified_by_map.merge(params[model_class.name.underscore.downcase.to_sym] || {})
    end
  end
  
  def perform_update params, model, fluxx_current_user=nil, controller=nil
    post_save_call_proc = self.post_save_call || lambda{|fluxx_current_user, model, params|true}
    skip_validation = model.send :instance_variable_get, ActionController::ControllerDslUpdate.skip_validation_constant

    if editable?(model, fluxx_current_user) && (skip_validation || model.valid?) && model.save(:validate => false) && post_save_call_proc.call(fluxx_current_user, model, params)
      remove_lock model, fluxx_current_user
      true
    else
      add_lock model, fluxx_current_user
      false
    end
    
  end

  def clear_deleted_at_if_pre_create model, params, fluxx_current_user=nil
    if pre_create_model
#     AML: Make sure we only clear the deleted_at column in the current user owns this reocrd and the record deleted at time is less than one day before the current time
      model.deleted_at = nil if (model.created_by_id == fluxx_current_user.id && model.deleted_at && (Time.now - model.deleted_at < 86400))
    end
  end
end