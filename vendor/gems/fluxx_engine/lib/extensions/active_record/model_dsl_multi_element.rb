class ActiveRecord::ModelDslMultiElement < ActiveRecord::ModelDsl
  # List of attributes that may have multiple elements
  attr_accessor :multi_element_attributes
  # List of attributes that may have 1 or 0 elements
  attr_accessor :single_element_attributes

  def add_multi_elements
    self.multi_element_attributes = []
    self.single_element_attributes = []
    
    # ESH: DO NOT CALL multi_element_choices directly; this could return records from other model types that also use multi_element_choices.  
    #   This is really used to seed the constituents, etc. classes
    if (MultiElementGroup.exists? rescue false)
      model_class.has_many :multi_element_choices, :foreign_key => :target_id
      groups = MultiElementGroup.find(:all, :conditions => {:target_class_name => model_class.name})
      blank_model_obj = model_class.new
      groups.each do |group|
        if blank_model_obj.respond_to? "#{group.name.singularize}_id"
          model_class.belongs_to group.name.singularize.to_sym, :class_name => 'MultiElementValue', :conditions => {:multi_element_group_id => group.id}
          @single_element_attributes << group.name.singularize
        else
          model_class.has_many group.name.to_sym, :class_name => 'MultiElementValue', :through => :multi_element_choices, :source => 'multi_element_value', 
               :conditions => "multi_element_group_id = '#{group.id}' and multi_element_choices.multi_element_value_id = multi_element_values.id"
          model_class.send :define_method, "choices_#{group.name}".to_sym do 
             group.multi_element_values
          end
          self.multi_element_attributes << group.name
        end
      end
    end
  end
end