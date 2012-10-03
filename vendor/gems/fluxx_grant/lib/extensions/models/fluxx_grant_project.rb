module FluxxGrantProject
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :title, :project_type_id, :lead_user_id, :favorite_user_ids]

  def self.included(base)
    base.send :include, ::FluxxProject

    base.has_many :project_requests
    
    base.acts_as_audited
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end
    
    base.insta_realtime do |insta|
      insta.delta_attributes = SEARCH_ATTRIBUTES
      insta.updated_by_field = :updated_by_id
    end
    base.insta_export do |insta|
      insta.filename = 'project'
      insta.headers = [['Date Created', :date], ['Date Updated', :date], 'Title', 'Description', 'Project Type', 'Lead User First', 'Lead User Last']
      insta.sql_query = "projects.created_at, projects.updated_at, projects.title, projects.description, ifnull(mev.description, mev.value),
                      users.first_name, users.last_name
                      from projects 
                      left outer join multi_element_choices mec ON mec.id = projects.project_type_id
                      left outer join multi_element_values mev ON mec.multi_element_value_id = mev.id
                      left outer join users ON users.id = projects.lead_user_id
                      where projects.id IN (?)"
    end
    
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    base.add_sphinx if base.respond_to?(:sphinx_indexes) && !(base.connection.adapter_name =~ /SQLite/i)
  end

  module ModelClassMethods
    def add_sphinx
      define_index :project_first do
        # fields
        indexes "lower(projects.title)", :as => :title, :sortable => true
        indexes "lower(projects.description)", :as => :description, :sortable => true

        # attributes
        has created_at, updated_at, deleted_at, project_type_id, lead_user_id

        has favorites.user(:id), :as => :favorite_user_ids

        set_property :delta => :delayed
      end
    end
  end

  module ModelInstanceMethods
    def related_requests granted_param=false
      project_requests.where({:granted => granted_param}).map{|pr| pr.request}.reject{|req| !req || req.deleted_at}.compact.sort_by{|req| [req.grant_agreement_at.to_i*-1, req.request_received_at.to_i*-1]}
    end

    def related_grants
      related_requests true
    end

    def autocomplete_to_s
      title
    end
  end
end
