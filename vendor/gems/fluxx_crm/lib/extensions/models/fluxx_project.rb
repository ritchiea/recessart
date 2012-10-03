module FluxxProject
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :title, :project_type_id, :lead_user_id]

  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.has_many :project_lists
    base.has_many :project_users
    base.has_many :project_organizations
    base.has_many :wiki_documents, :as => :model, :conditions => {:deleted_at => nil}
    base.belongs_to :lead_user, :class_name => 'User', :foreign_key => :lead_user_id
    base.has_many :model_documents, :as => :documentable
    base.has_many :notes, :as => :notable, :conditions => {:deleted_at => nil}
    base.has_many :group_members, :as => :groupable
    base.has_many :groups, :through => :group_members
    base.has_many :work_tasks, :as => :taskable, :conditions => {:deleted_at => nil}
    
    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end
    base.insta_export
    base.insta_multi
    base.insta_favorite
    base.insta_lock
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def related_users
      project_users.map{|pu| pu.user}.compact.sort_by{|u| [u.last_name || '', u.first_name || '']}
    end
    
    def related_organizations
      project_organizations.map{|ro| ro.organization}.compact.sort_by{|o| o.name || ''}
    end

    def to_liquid
      {"title" => title, "description" => description}
    end
  end
end
