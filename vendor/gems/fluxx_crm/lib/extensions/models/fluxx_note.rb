module FluxxNote
  SEARCH_ATTRIBUTES = [:notable_type, :notable_id]

  def self.included(base)
    base.validates_presence_of     :note
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :notable, :polymorphic => true
    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :locked_until, :locked_by_id, :delta]})
    
    base.insta_export
    base.insta_lock

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end

    base.insta_realtime do |insta|
      insta.delta_attributes = [:updated_at, :notable_id, :notable_type]
      insta.updated_by_field = :updated_by_id
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