module FluxxRole
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :id]
  
  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.has_many :role_users
    base.validates_uniqueness_of :name, :scope => [:roleable_type, :deleted_at]

    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
      insta.derived_filters = {}
    end

    base.insta_template do |insta|
      insta.entity_name = 'role'
      insta.add_methods []
      insta.remove_methods [:id]
    end

    base.insta_utc do |insta|
      insta.time_attributes = [] 
    end
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end
  

  module ModelClassMethods
    def all_roles
      Role.where(:deleted_at => nil).order('name asc').all
    end
  end
  
  module ModelInstanceMethods
  end
end