class ActiveRecord::ModelDslRealtime < ActiveRecord::ModelDsl
  # attributes are the list of fields that should be tracked in the realtime feed
  attr_accessor :delta_attributes
  # the name of the field for modified_by
  attr_accessor :updated_by_field
  # post hooks
  attr_accessor :after_realtime_blocks
  
  def initialize model_class
    super model_class
    self.after_realtime_blocks = []
  end
  
  def clear_after_realtime
    self.after_realtime_blocks = []
  end
  
  def after_realtime &after_block
    self.after_realtime_blocks << after_block
  end
  
  def call_after_realtimes model, params
    if after_realtime_blocks
      after_realtime_blocks.each do |cur_block|
        cur_block.call model, params
      end
    end
  end
  
  def calculate_attributes model
    if delta_attributes
      delta_attributes.inject({}) do |acc, attribute_pair|
        attribute, table_name = attribute_pair
        acc[attribute] = model.send(attribute)
        acc
      end
    end
  end
  
  def realtime_user_id model
    model.send(updated_by_field) if updated_by_field
  end
  
  def realtime_model_id model
    if model.respond_to? :realtime_update_id
      model.realtime_update_id
    else
      model.id
    end
  end
  
  def realtime_class_name model
    if model.respond_to? :realtime_classname
      model.realtime_classname
    else
      model.class.name
    end
  end
  
  def realtime_create_callback model
    write_realtime(model, :action => 'create', :user_id => realtime_user_id(model), :model_id => realtime_model_id(model), :model_class => realtime_class_name(model), :type_name => model.class.name, :delta_attributes => calculate_attributes(model).to_json)
  end
  
  def realtime_update_callback model
    if model.respond_to?(:deleted_at) && !model.deleted_at.blank?
      realtime_destroy_callback model
    else
      write_realtime(model, :action => 'update', :user_id => realtime_user_id(model), :model_id => realtime_model_id(model), :model_class => realtime_class_name(model), :type_name => model.class.name, :delta_attributes => calculate_attributes(model).to_json)
    end
  end
  
  def realtime_destroy_callback model
    write_realtime(model, :action => 'delete', :user_id => realtime_user_id(model), :model_id => realtime_model_id(model), :model_class => realtime_class_name(model), :type_name => model.class.name, :delta_attributes => calculate_attributes(model).to_json)
  end
  
  def write_realtime model, params
    RealtimeUpdate.create params 
    call_after_realtimes model, params
  end
end