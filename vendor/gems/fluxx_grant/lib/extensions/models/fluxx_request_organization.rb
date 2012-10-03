module FluxxRequestOrganization
  SEARCH_ATTRIBUTES = [:request_id]

  def self.included(base)
    base.belongs_to :request
    base.belongs_to :organization
    # base.after_commit :update_related_data
    base.acts_as_audited
    base.send :attr_accessor, :organization_lookup

    base.validates_presence_of :organization_id
    base.validates_presence_of :request_id
    base.validates_uniqueness_of :organization_id, :scope => :request_id
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end
    base.insta_export
    base.insta_realtime
    base.insta_lock
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def update_related_data
      if Request.respond_to? :indexed_by_sphinx?
        Request.without_realtime do
          if request_id
            Request.update_all 'delta = 1', ['id in (?)', request_id]
            req = Request.find(request_id)
            req.delta = 1
            req.save 
          end
        end
        Organization.without_realtime do
          if organization_id
            Organization.update_all 'delta = 1', ['id in (?)', organization_id]
            org = Organization.find(organization_id)
            org.delta = 1
            org.save 
          end
        end
      end
    end
  end
end