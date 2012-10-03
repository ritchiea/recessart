module FluxxProjectRequest
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :granted, :project_id]

  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :project
    base.belongs_to :request
   
    base.validates :request, :presence => true
    base.validates :project, :presence => true

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end
    base.insta_export
    
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
