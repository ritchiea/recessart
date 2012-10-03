class MultiElementValue < ActiveRecord::Base
  has_many :multi_element_choices
  belongs_to :multi_element_group
  belongs_to :dependent_multi_element_value, :class_name => 'MultiElementValue', :foreign_key => 'dependent_multi_element_value_id'

  SEARCH_ATTRIBUTES = [:dependent_multi_element_value_id, :multi_element_group_id]
  insta_search do |insta|
    insta.filter_fields = SEARCH_ATTRIBUTES
  end
  
  def to_s
    description || value
  end
  
  def children_values
    MultiElementValue.where(:dependent_multi_element_value_id => self.id).all
  end
end
