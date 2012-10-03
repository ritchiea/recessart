# This class encapsulates:
#  * bindings which link a particular model instance to an entity
class ActiveRecord::ModelTemplateBinding
  attr_accessor :bindings
  
  def initialize bindings_param = {}
    self.bindings = bindings_param
  end
  
  def add_binding var_name, model
    bindings[var_name.to_s] = model
  end
  
  def clone
    ActiveRecord::ModelTemplateBinding.new bindings.clone
  end
  
  def model_evaluate variable_name, method_name
    model = bindings[variable_name]
    if model && model.respond_to?(:evaluate_model_method)
      model.evaluate_model_method method_name
    else
      ActiveRecord::Base.logger.warn "Looks like model class #{model.class.name} for name #{variable_name} does not respond to evaluate_model_method.  Perhaps you forgot to invoke insta_template on the model?"
      nil
    end
  end

  def model_list_evaluate variable_name, method_name
    model = bindings[variable_name]
    if model && model.respond_to?(:evaluate_model_list_method)
      model.evaluate_model_list_method method_name
    end
  end
end