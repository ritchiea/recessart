module FluxxGrantRoleUser
  def self.included(base)
    base.belongs_to :program, :class_name => 'Program', :foreign_key => :roleable_id  # So we can do a sphinx index
    base.belongs_to :initiative, :class_name => 'Initiative', :foreign_key => :roleable_id  # So we can do a sphinx index
    base.send :include, ::FluxxRoleUser
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
  end
end