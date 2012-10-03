module FluxxWorkTask
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :id, :taskable_type, :taskable_id, :assigned_user_id, :task_completed]
  
  def self.included(base)
    base.validates_presence_of :task_text
    base.belongs_to :taskable, :polymorphic => true
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :assigned_user, :class_name => 'User', :foreign_key => 'assigned_user_id'
    base.has_many :wiki_documents, :as => :model, :conditions => {:deleted_at => nil}
    base.has_many :model_documents, :as => :documentable
    base.has_many :notes, :as => :notable, :conditions => {:deleted_at => nil}
    base.before_save :adjust_completed_at

    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
      insta.derived_filters = {}
    end

    base.insta_multi
    base.insta_lock

    base.insta_template do |insta|
      insta.entity_name = 'work_task'
      insta.add_methods []
      insta.remove_methods [:id]
    end

    base.insta_favorite
    base.insta_utc do |insta|
      insta.time_attributes = [:due_at]
    end

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end
  

  module ModelClassMethods
  end
  
  module ModelInstanceMethods
    def adjust_completed_at
      self.completed_at = if task_completed
        Time.now
      else
        nil
      end
    end
  end
end