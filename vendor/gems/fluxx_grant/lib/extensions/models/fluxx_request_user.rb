module FluxxRequestUser
  SEARCH_ATTRIBUTES = [:request_id]

  def self.included(base)
    base.belongs_to :request
    base.belongs_to :user
    base.acts_as_audited

    base.validates_presence_of :user_id
    base.validates_presence_of :request_id
    base.validates_uniqueness_of :user_id, :scope => :request_id
    
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
  end
end