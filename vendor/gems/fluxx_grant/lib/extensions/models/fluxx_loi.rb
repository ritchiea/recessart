module FluxxLoi
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :id, :applicant, :organization_name, :email, :phone, :project_title]
  
  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :request
    base.belongs_to :user
    base.belongs_to :organization
    base.validates_presence_of   :applicant
    base.validates_presence_of   :organization_name
    base.validates_presence_of   :email

    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES + [:organization_linked, :applicant_linked]
      insta.derived_filters = {}
    end

    base.insta_realtime do |insta|
      insta.delta_attributes = SEARCH_ATTRIBUTES
      insta.updated_by_field = :updated_by_id
    end
    base.insta_multi
    base.insta_export do |insta|
      insta.filename = 'loi'
      insta.headers = [['Date Created', :date], ['Date Updated', :date]]
      insta.sql_query = "created_at, updated_at
                from lois
                where id IN (?)"
    end
    base.insta_lock

    base.insta_template do |insta|
      insta.entity_name = 'loi'
      insta.add_methods []
      insta.remove_methods [:id]
    end

    base.insta_favorite
    base.insta_utc do |insta|
      insta.time_attributes = [] 
    end
    
#    base.insta_workflow do |insta|
      # insta.add_state_to_english :new, 'New Request'
      # insta.add_event_to_english :recommend_funding, 'Recommend Funding'
#    end
    base.insta_utc do |insta|
      insta.time_attributes = [:grant_begins_at]
    end


    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    
#    base.send :include, AASM
#    base.add_aasm
    base.add_sphinx if base.respond_to?(:sphinx_indexes) && !(base.connection.adapter_name =~ /SQLite/i)
  end
  

  module ModelClassMethods
    def add_aasm
      aasm_column :state
      aasm_initial_state :new
    end

    def add_sphinx
      define_index :loi_first do
        # fields
        indexes "lower(lois.applicant)", :as => :applicant, :sortable => true
        indexes "lower(lois.organization_name)", :as => :organization_name, :sortable => true
        indexes "lower(lois.project_title)", :as => :project_title, :sortable => true

        # attributes
        has created_at, updated_at, deleted_at, email, phone

        has favorites.user(:id), :as => :favorite_user_ids

        set_property :delta => :delayed
        has "IF(lois.organization_id is not null, 1, 0)", :as => :organization_linked, :type => :boolean
        has "IF(lois.user_id is not null, 1, 0)", :as => :applicant_linked, :type => :boolean
      end
    end
  end

  module ModelInstanceMethods
    def first_name
      applicant.gsub(/\s+/, ' ').split(' ').first
    end

    def last_name
      applicant.gsub(/\s+/, ' ').split(' ').last
    end

    def user_matches params = {}
      first = params && params[:first_name] ? params[:first_name] : first_name
      last = params && params[:last_name] ? params[:last_name] : last_name
      User.find(:all, :conditions => ["(first_name like ? and last_name like ?) and deleted_at is null", "%#{first}%", "%#{last}%"], :order => "first_name, last_name asc", :limit => 20)
    end

    def organization_matches params = {}
      org = params && params[:organization_name] ? params[:organization_name] : organization_name
      Organization.find(:all, :conditions => ["(name like ?) and deleted_at is null", "%#{org}%"], :order => "name asc", :limit => 20)
    end

    def link_user user
      if user.id
        update_attribute("user_id", user.id)
        if !user.user_profile
          user.update_attribute "user_profile_id", UserProfile.where(:name => 'Grantee').first.id
          user.save
        end
        # Only add the grantee roles if the user's profile is Grantee
        if user.user_profile.name == "Grantee"
          Program.where(:retired => 0).each do |program|
            user.has_role! "Grantee", program
          end
        end
        set_loi_user_primary_org
        #todo email login information
      end
    end

    def link_organization org
      update_attribute("organization_id", org.id)
      set_loi_user_primary_org
    end

    def set_loi_user_primary_org
      if user && organization && !user.primary_organization
        user_org = UserOrganization.where(:user_id => user.id, :organization_id => organization.id).first
        unless user_org
          user_org = UserOrganization.new({:user_id => user.id, :organization_id => organization.id})
          user_org.save
        end
        user.update_attribute "primary_user_organization_id", user_org.id
      end
    end
  end
end