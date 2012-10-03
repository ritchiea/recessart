module FluxxProjectList
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :project_id]

  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :project
    base.has_many :project_list_items
    base.has_many :work_tasks, :as => :taskable, :conditions => {:deleted_at => nil}
    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end
    base.insta_export
    base.insta_multi
    base.insta_lock
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def is_numbered?
      list_type && list_type.value == 'Numbers'
    end
    def is_bulleted?
      list_type && list_type.value == 'Bulleted'
    end
    def is_todo?
      list_type && list_type.value == 'To-Do'
    end
  end
end