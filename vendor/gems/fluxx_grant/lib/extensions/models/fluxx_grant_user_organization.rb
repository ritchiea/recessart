module FluxxGrantUserOrganization
  def self.included(base)
    base.belongs_to :program, :class_name => 'Program', :foreign_key => :roleable_id  # So we can do a sphinx index
    base.send :include, ::FluxxUserOrganization
    # base.after_commit :update_related_data
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def update_related_data
      if User.respond_to? :indexed_by_sphinx?
        Organization.without_realtime do
          if organization_id
            Organization.update_all 'delta = 1', ['id = ?', organization_id]
            o = Organization.find(organization_id)
            o.delta = 1
            o.save 
          end
        end
        User.without_realtime do
          if user_id
            User.update_all 'delta = 1', ['id = ?', user_id]
            o = User.find(user_id)
            o.delta = 1
            o.save 
          end
        end
      end
    end
  end
end