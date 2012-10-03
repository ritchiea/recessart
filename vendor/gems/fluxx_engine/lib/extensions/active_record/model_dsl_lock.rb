class ActiveRecord::ModelDslLock < ActiveRecord::ModelDsl
  def self.lock_time_interval= lock_time_interval_param
    @lock_time_interval = lock_time_interval_param
  end
  
  def self.lock_time_interval
    @lock_time_interval || 5.minutes
  end
  
  def editable? model, fluxx_current_user
    !(is_lockable?(model)) || model.locked_until.nil? || (model.locked_until.to_i + self.class.lock_time_interval) < Time.now.to_i || model.locked_by.nil? || 
      (fluxx_current_user && model.locked_by == fluxx_current_user)
  end
  
  def add_lock model, fluxx_current_user
    if fluxx_current_user && editable?(model, fluxx_current_user)
      add_lock_update_attributes model, fluxx_current_user
      true
    end
  end
  
  def extend_lock model, fluxx_current_user, extend_interval=ActiveRecord::ModelDslLock.lock_time_interval
    if fluxx_current_user && editable?(model, fluxx_current_user)
      extend_lock_update_attributes model, fluxx_current_user, extend_interval
      true
    end
  end

  def remove_lock model, fluxx_current_user
    if editable?(model, fluxx_current_user)
      remove_lock_update_attributes model
      true
    end
  end

  protected
  def add_lock_update_attributes model, fluxx_current_user, interval=ActiveRecord::ModelDslLock.lock_time_interval
    current_model = model.class.find model.id
    if is_lockable?(current_model)
      current_model.update_attribute_without_log :locked_until, Time.now + interval
      current_model.update_attribute_without_log :locked_by_id, fluxx_current_user.id
    end
  end
  
  # Either extend the current lock by ActiveRecord::ModelDslLock.lock_time_interval minutes or add a lock ActiveRecord::ModelDslLock.lock_time_interval from Time.now
  def extend_lock_update_attributes model, fluxx_current_user, extend_interval=ActiveRecord::ModelDslLock.lock_time_interval
    current_model = model.class.find model.id
    if is_lockable?(current_model)
      do_lock_update_attributes current_model, fluxx_current_user, extend_interval
    end
  end
  
  def do_lock_update_attributes model, fluxx_current_user, extend_interval=ActiveRecord::ModelDslLock.lock_time_interval
    current_model = model.class.find model.id
    if current_model.locked_until && current_model.locked_until > Time.now
      interval = current_model.locked_until + extend_interval
      current_model.update_attribute_without_log :locked_until, interval
      current_model.locked_until = interval
    else
      interval = Time.now + extend_interval
      current_model.update_attribute_without_log :locked_until, interval
      current_model.locked_until = interval
    end
    current_model.update_attribute_without_log :locked_by_id, fluxx_current_user.id
    current_model.locked_by_id = fluxx_current_user.id
    
  end
  
  def remove_lock_update_attributes model
    current_model = model.class.find model.id
    if is_lockable?(current_model)
      current_model.update_attributes_without_log :locked_until => nil, :locked_by => nil
      current_model.locked_until = nil
      current_model.locked_by = nil
    end
  end
  
  def is_lockable? model
    model.respond_to?(:locked_until) && model.respond_to?(:locked_by)
  end
end