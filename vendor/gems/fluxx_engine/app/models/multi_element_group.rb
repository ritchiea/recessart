class MultiElementGroup < ActiveRecord::Base
  has_many :multi_element_values
  
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :name, :attribute_type, :model_type]
  
  insta_search do |insta|
    insta.filter_fields = SEARCH_ATTRIBUTES
    insta.derived_filters = {}
  end

  # Allow for STI; look for the specific name first, then bump up to the superclass; we might call it Request for GrantRequest/FipRequest.  First look for GrantRequest then Request
  def self.find_for_model_or_super model, name
    klass = if model.is_a? Class
      model
    else
      model.class
    end
    group = nil
    while klass && !group
      group = MultiElementGroup.find :first, :conditions => {:name => name, :target_class_name => klass.name}
      klass = klass.superclass
      klass = nil if klass == ActiveRecord::Base
    end
    group
  end
  
  def self.find_values model, name
    group = MultiElementGroup.find_for_model_or_super model, name
    if group
      MultiElementValue.find(:all, :conditions => ['multi_element_group_id = ?', group.id], :order => 'description asc, value asc').collect {|p| [ (p.description || p.value), p.id ] }
    else
      []
    end
  end
  
  def elements_to_dropdown
    MultiElementValue.find(:all, :conditions => ['multi_element_group_id = ?', self.id], :order => 'description asc, value asc').collect {|p| [ (p.description || p.value), p.id ] }
  end
  
end
