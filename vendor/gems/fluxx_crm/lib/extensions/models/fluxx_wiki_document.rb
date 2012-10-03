module FluxxWikiDocument
  SEARCH_ATTRIBUTES = [:created_at, :updated_at]

  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :model, :polymorphic => true
    base.belongs_to :wiki_document_template
    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})
    base.before_create :check_template
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end
    base.insta_export
    base.insta_multi
    base.insta_lock
    base.insta_realtime do |insta|
      insta.delta_attributes = SEARCH_ATTRIBUTES
      insta.updated_by_field = :updated_by_id
      insta.after_realtime do |model, params|
        model.model.trigger_realtime_update if model.model && model.model.respond_to?(:trigger_realtime_update)
      end
    end
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def check_template
      if wiki_document_template
        self.note = wiki_document_template.document
      end
    end
  end
end