class ActiveRecord::ModelDslRole < ActiveRecord::ModelDsl
  # A mapping of events to roles
  attr_accessor :event_role_mappings
  attr_accessor :admin_edit_roles
  attr_accessor :extract_related_object_proc
  
  def extract_related_object &block
    self.extract_related_object_proc = block
  end
  
  def initialize model_class
    super model_class
    self.event_role_mappings = HashWithIndifferentAccess.new
    self.admin_edit_roles = []
  end
  
  def add_admin_edit_for_roles role
    if role.is_a? Array
      role.each {|a_role| admin_edit_roles << a_role.to_s}
    else
      self.admin_edit_roles << role.to_s
    end
  end
  
  def admin_edit_allowed_for_user? user, related_object_model
    retval = if admin_edit_roles
      !(admin_edit_roles.select do |role_name|
        user.has_role?(role_name, related_object_model)
      end).empty?
    end
    
    retval
  end
  
  def add_event_roles event, related_object, roles
    roles = [roles] unless roles.is_a? Array
    
    current_related_mapping = event_role_mappings[event]
    current_related_mapping = {} unless current_related_mapping
    current_mapping = current_related_mapping[related_object]
    current_mapping = [] unless current_mapping
    current_related_mapping[related_object] = roles | current_mapping # Merge in the new roles so we don't have dupes
    event_role_mappings[event] = current_related_mapping
  end
  
  def roles_for_event_and_related_object event, related_object=nil
    current_related_mapping = event_role_mappings[event]
    if current_related_mapping
      current_related_mapping[related_object]
    end || []
  end
  
  def clear_all_event_roles
    event_role_mappings.clear
  end

  def clear_event event
    event_role_mappings[event] = nil
  end
  
  def check_if_events_allowed? user, events, related_object_models=[]
    events_available = events.select do |event| 
      event = event.first if event.is_a? Array
      event_allowed_for_user?(user, event, related_object_models)
    end
    events_available.empty? ? nil : events_available
  end
  
  
  def event_allowed_for_user? user, event, related_object_models=[]
    return true if user.is_admin?
    related_object_models = [related_object_models] unless related_object_models.is_a?(Array)
    event_mappings = event_role_mappings[event]
    event_mappings && !(event_mappings.keys.select do |related_object|
      related_object_models.any? do |related_object_model|
        related_object_model.class == related_object && event_mappings[related_object] && !(event_mappings[related_object].select do |role|
          user.has_role?(role, related_object_model)
        end).empty?
      end
    end).empty?
  end
end