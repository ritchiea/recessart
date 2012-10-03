module ApplicationEngineHelper
  # Use GET
  def current_index_path options={}
    send "#{@controller.controller_path}_path", options
  end

  # Use POST
  def current_create_path options={}
    send "#{controller.controller_path}_path", options
  end
  
  # Use GET
  def current_new_path options={}
    send "new_#{controller.controller_path.singularize}_path", options
  end

  # Use GET
  def current_edit_path model_id, options={}
    send "edit_#{controller.controller_path.singularize}_path", options.merge({:id => model_id})
  end

  # Use GET
  def current_show_path model_id, options={}
    send "#{controller.controller_path.singularize}_path", options.merge({:id => model_id})
  end

  # Use PUT
  def current_put_path model_id, options={}
    send "#{controller.controller_path.singularize}_path", options.merge({:id => model_id})
  end

  # Use DELETE
  def current_delete_path model_id, options={}
    send "#{controller.controller_path.singularize}_path", options.merge({:id => model_id})
  end
end