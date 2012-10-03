module Fluxx<%= model_class_name %>
  extend FluxxModuleHelper

  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :id]
  
  when_included do
    belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'

    acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})

    insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
      insta.derived_filters = {}
    end

    insta_realtime do |insta|
      insta.delta_attributes = SEARCH_ATTRIBUTES
      insta.updated_by_field = :updated_by_id
    end
    insta_multi
    insta_export do |insta|
      insta.filename = '<%= model_class_singular_table_name %>'
      insta.headers = [['Date Created', :date], ['Date Updated', :date]]
      insta.sql_query = "created_at, updated_at
                from <%= model_class_plural_table_name %>
                where id IN (?)"
    end
    insta_lock

    insta_template do |insta|
      insta.entity_name = '<%= model_class_singular_table_name %>'
      insta.add_methods []
      insta.remove_methods [:id]
    end

    insta_favorite
    insta_utc do |insta|
      insta.time_attributes = [] 
    end
    
    insta_workflow do |insta|
      # insta.add_state_to_english :new, 'New Request'
      # insta.add_event_to_english :recommend_funding, 'Recommend Funding'
    end
    
    # add_sphinx if respond_to?(:sphinx_indexes) && !(connection.adapter_name =~ /SQLite/i)
  end
  

  class_methods do
    def add_sphinx
      define_index :<%= model_class_singular_table_name %>_first do
        # fields
        

        # attributes
        has created_at, updated_at
      end
    end
  end
end