module FluxxRequestTransactionFundingSource
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :id]
  
  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :request_transaction
    base.belongs_to :request_funding_source

    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
      insta.derived_filters = {}
    end

    base.insta_realtime do |insta|
      insta.delta_attributes = SEARCH_ATTRIBUTES
      insta.updated_by_field = :updated_by_id
    end
    base.insta_multi

    base.insta_utc do |insta|
      insta.time_attributes = [] 
    end
    
    
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