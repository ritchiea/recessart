# insta_template do |insta|
#   insta_entity.add_methods [:main_org, :primary_org]
#   insta_entity.add_list_method :request_transactions, RequestTransaction
#   insta_entity.remove_methods [:main_org, :primary_org]
#   insta_entity.load {|model| model}
# end

class ActiveRecord::ModelDslTemplate < ActiveRecord::ModelDsl
  attr_accessor :entity_name
  # extra methods
  attr_accessor :extra_methods
  # extra methods that return a list and can be used with iterators
  attr_accessor :extra_list_methods
  # do not use methods
  attr_accessor :do_not_use_methods
  
  def initialize model_class_param
    super model_class_param
    self.entity_name = model_class_param.name.tableize.singularize.downcase if model_class_param
    self.extra_methods = []
    self.extra_list_methods = []
    self.do_not_use_methods = []

    @method_list = if inherits_from_activerecord?(self.model_class)
      self.model_class.column_names
    else
      self.public_instance_methods
    end
  end
  
  
  def add_methods methods
    self.extra_methods = self.extra_methods + (methods.map{|meth| meth.to_s})
  end

  def add_list_method method, klass
    self.extra_list_methods << [method, klass]
  end
  
  def remove_methods methods
    self.do_not_use_methods = self.do_not_use_methods + (methods.map{|meth| meth.to_s})
  end
  
  def all_methods_allowed model
    if model.kind_of? self.model_class
      string_extra_methods = extra_methods.map {|meth| meth.to_s}
      string_do_not_use_methods = do_not_use_methods.map {|meth| meth.to_s}
      @method_list + string_extra_methods - string_do_not_use_methods
    end || []
  end

  def all_list_methods_allowed model
    if model.kind_of? self.model_class
      extra_list_methods
    end || []
  end

  def method_allowed? model, method_name
    if model.kind_of? self.model_class
      all_methods_allowed(model).include? method_name
    end
  end
  
  
  def list_method_allowed? model, method_name
    if model.kind_of? self.model_class
      extra_list_methods.map{|method_pair| method_pair.first.to_s}.include? method_name
    end
  end
  
  
  def inherits_from_activerecord? klass
    matches = false
    while klass = klass.superclass
      matches = true if klass == ActiveRecord::Base
    end
    matches
  end
  
  def evaluate_model_method model, method_name
    # Allow for dot notation for the method_name, can be:
    # method.method.method, etc.
    methods = method_name.split "."
    method_name = methods.first
    
    result = model.send(method_name) if method_allowed?(model, method_name)
    if methods.size == 1
      result
    else
      result.evaluate_model_method(methods[1..(methods.size - 1)].join(".")) if result && result.respond_to?(:evaluate_model_method)
    end
  end
  
  def evaluate_model_list_method model, method_name
    model.send(method_name) if list_method_allowed?(model, method_name)
  end
  
  def process_template model, document, view_context
    binding = create_bindings model
    c = CurlyParser.new
    doc = c.parse document
    
    sb = evaluate_template model, doc, binding, view_context
    sb.string
  end
  
  def process_liquid_template model, document, view_context
    Liquid::Template.parse(document).render(entity_name => model)
  end
  
  protected
  
  def create_bindings model
    # build a variable for each entity to create bindings
    binding = ActiveRecord::ModelTemplateBinding.new
    binding.add_binding entity_name, model
    binding.add_binding 'today', Time.now
    binding
  end
  
  # This will replace fluxx_iterator, fluxx_conditional, fluxx_value elements within a curly_parser instance
  MAX_DEPTH = 100
  def evaluate_template model, doc, binding, view_context, sb = StringIO.new, depth=0
    return sb if depth > MAX_DEPTH
    doc.each do |element|
      iter_map = element.attributes
      if element.element_name == 'iterator'
        # {{iterator method='instruments' new_variable='instrument' variable='musician'}}{{/iterator}}
        variable_name = iter_map['variable']
        new_variable_name = iter_map['new_variable']
        
        list = binding.model_list_evaluate iter_map['variable'], iter_map['method']
        unless list
          raise SyntaxError.new "Could not derive a model from model #{iter_map['variable'].inspect}, bindings=#{binding.inspect} for method #{iter_map['method']}, for element '#{element.inspect}'"
        end

        list.each do |new_model|
          cloned_binding = binding.clone
          cloned_binding.add_binding new_variable_name, new_model
          evaluate_template model, element.children, cloned_binding, view_context, sb, depth + 1
        end
      elsif element.element_name == 'if'
        # {{if variable='instrument' method='name' is_blank='true'}}{{else}}{{/else}}{{/if}}
        variable_name = iter_map['variable']
        method_value = if iter_map['is_blank']
          binding.model_evaluate iter_map['variable'], iter_map['method']
        elsif iter_map['is_empty']
          binding.model_list_evaluate iter_map['variable'], iter_map['method']
        end
        if iter_map['is_blank'] && iter_map['is_blank'].downcase.strip == 'true' && method_value.blank?
          evaluate_template model, element.children, binding, view_context, sb, depth + 1
        elsif iter_map['is_blank'] && iter_map['is_blank'].downcase.strip == 'false' && !method_value.blank?
          evaluate_template model, element.children, binding, view_context, sb, depth + 1
        elsif iter_map['is_empty'] && iter_map['is_empty'].downcase.strip == 'true' && method_value && method_value.empty?
          evaluate_template model, element.children, binding, view_context, sb, depth + 1
        elsif iter_map['is_empty'] && iter_map['is_empty'].downcase.strip == 'false' && method_value && !method_value.empty?
          evaluate_template model, element.children, binding, view_context, sb, depth + 1
        else
          # try to find an else condition among the children
          else_clause = element.children.select{|child_element| child_element.element_name == 'else'}.first
          evaluate_template model, else_clause.children, binding, view_context, sb, depth + 1 if else_clause
        end
      elsif element.element_name == 'value'
        # {{value variable='instrument' method='name'/}}
        replacement_value = if iter_map['method']
          binding.model_evaluate iter_map['variable'], iter_map['method']
        else
          binding.bindings[iter_map['variable']]
        end
        if iter_map['as']
          options = if iter_map['unit']
            {:unit => iter_map['unit']}
          end || {}
          replacement_value = render_as(iter_map['as'], replacement_value, options)
        end
        
        # NOTE convert linebreaks must come last in the list of modifiers because it calls to_s
        unless iter_map['convert_linebreaks'] == 'false'
          replacement_value = (replacement_value || '').to_s.gsub("\n","<br>\n")
        end
        sb << replacement_value
      elsif element.element_name == 'template'
        # {{template file_name='request_evaluation_metrics/_request_evaluation_metrics_list.html.haml' variable='request' method='grant_agreement_at' local_variable_name='model'/}}
        method_value = if iter_map['method']
          binding.model_evaluate iter_map['variable'], iter_map['method']
        else
          binding.bindings[iter_map['variable']]
        end
        local_variable_name = iter_map['local_variable_name'] || :model
        file_name = iter_map['file_name']
        possible_files = ActionController::Base.view_paths.map {|v| "#{v.instance_variable_get '@path'}/#{file_name}"}
        found_file_name = possible_files.map{|file_name| file_name if File.exist?(file_name) }.compact.first
        # TODO ESH: limit the templates available via an API
        if found_file_name
          template = File.read(found_file_name)
          sb << Haml::Engine.new(template).render(view_context, {local_variable_name => method_value, :invoked_from_template => true})
        end
      elsif element.element_name == 'text'
        sb << element.text
      end
    end

    sb
  end
  
  def render_as as, value, options={}
    case as
    when 'date_dmy' then value.dmy if value.kind_of?(Time)
    when 'date_full_dmy' then value.full_dmy if value.kind_of?(Time)
    when 'date_mdy' then value.mdy if value.kind_of?(Time)
    when 'date_full' then value.full if value.kind_of?(Time)
    when 'currency' then value.to_currency(options) if value.kind_of?(Fixnum)
      
    end || value
  end
end