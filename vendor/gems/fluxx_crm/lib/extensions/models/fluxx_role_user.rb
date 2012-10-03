module FluxxRoleUser
  def self.included(base)
    base.belongs_to :created_by,  :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :user
    base.belongs_to :role
    base.insta_search
    base.insta_export
    base.validates_presence_of :roleable_id, :if => :needs_validation_roleable

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    def find_by_roleable related_object
      if related_object
        self.joins(:role).where(:roleable_id => related_object.id, :roles => {:roleable_type => related_object.class.name})
      else
        []
      end
    end
    
  end

  module ModelInstanceMethods
    # Force validation of roleable if roleable_type is supplied
    def needs_validation_roleable
      role.roleable_type if role
    end
  end
end