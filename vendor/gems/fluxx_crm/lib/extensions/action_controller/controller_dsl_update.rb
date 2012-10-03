class ActionController::ControllerDslUpdate < ActionController::ControllerDsl
  def add_workflow
    if model_class.public_method_defined?(:current_allowed_events)
      @check_for_workflow = true
      self.pre do |conf|
        self.pre_model = conf.load_existing_model params
        # validate documents on state change/event actions - except for send_back or reject/unreject events
        if params[:event_action]
          if self.pre_model.respond_to?(:promotion_event)
            self.pre_model.promotion_event = true 
            self.pre_model.send :instance_variable_set, ActionController::ControllerDslUpdate.skip_validation_constant, true
          else
            ActiveRecord::Base.logger.warn "Class #{self.pre_model.class.name} does not have promotion_event accessor defined, you should probably add it for workflow"
          end
        end
      end

    end
  end
  
  define_method :perform_update_with_specific do |*params|
    params, model, fluxx_current_user, controller = params
    result = perform_update_without_specific params, model, fluxx_current_user
    if @check_for_workflow
      event_action = params[:event_action]
      if event_action
        event_allowed = if model.respond_to?(:event_allowed?)
          model.event_allowed?(event_action, fluxx_current_user) # Limit them by role
        else
          true
        end

        if controller
          if event_allowed
            if (model.is_non_validating_event?(event_action) || model.valid?) && model.insta_fire_event(event_action, fluxx_current_user)
              model.save(:validate => false)
              # Go on with life, the state transition happened uneventfully
            else
              # Something is wrong; send the user back to the show page
            
              (controller.send :flash)[:error] = I18n.t(:unable_to_promote) + model.errors.full_messages.to_sentence + '.'
          
              extra_options = {:id => model.id}
              controller.send :head, 201, :location => model
              result = false
            end
          else
            # p "User is not allowed to do #{event_action}; lacks required permissions"
            raise AASM::InvalidTransition.new "User is not allowed to do #{event_action}; lacks required permissions"
          end
        end
      end
    end
    result
  end
  alias_method_chain :perform_update, :specific
  
end