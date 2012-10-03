module FluxxRequestReview
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :id]
  
  def self.included(base)
    base.belongs_to :request
    base.belongs_to :grant, :class_name => 'GrantRequest', :foreign_key => 'request_id', :conditions => {:granted => true}

    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'

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
    base.insta_export do |insta|
      insta.filename = 'request_review'
      insta.headers = [['Date Created', :date], ['Date Updated', :date]]
      insta.sql_query = "created_at, updated_at
                from request_reviews
                where id IN (?)"
    end
    base.insta_lock

    base.insta_template do |insta|
      insta.entity_name = 'request_review'
      insta.add_methods []
      insta.remove_methods [:id]
    end

    base.insta_favorite
    base.insta_utc do |insta|
      insta.time_attributes = [] 
    end
    
#    base.insta_workflow do |insta|
#      # insta.add_state_to_english :new, 'New Request'
#      # insta.add_event_to_english :recommend_funding, 'Recommend Funding'
#    end
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    
#    base.send :include, AASM
#    base.add_aasm
#    base.add_sphinx if base.respond_to?(:sphinx_indexes) && !(base.connection.adapter_name =~ /SQLite/i)
  end
  

  module ModelClassMethods
#    def add_aasm
#      aasm_column :state
#      aasm_initial_state :new
#    end
    
#    def add_sphinx
#      define_index :request_review_first do
#        # fields
#        # attributes
#        has created_at, updated_at
#      end
#    end
  end
  
  module ModelInstanceMethods
    def relates_to_user? user
      (user.id == self.created_by_id)
    end
  end
end