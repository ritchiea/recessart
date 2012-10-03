module FluxxGrantUser
  SEARCH_ATTRIBUTES = [:program_ids, :grant_program_ids, :test_user_flag, :grant_sub_program_ids, :organization_id, :state, :updated_at, :request_ids, :favorite_user_ids, :user_profile_id]
  
  def self.included(base)
    base.has_many :request_users
    base.has_many :users, :through => :request_users
    base.has_many :program_lead_requests, :class_name => 'Request', :foreign_key => :program_lead_id
    base.has_many :grantee_org_owner_grants, :class_name => 'Request', :foreign_key => :grantee_org_owner_id, :conditions => {:granted => 1, :deleted_at => nil}
    base.has_many :grantee_signatory_grants, :class_name => 'Request', :foreign_key => :grantee_signatory_id, :conditions => {:granted => 1, :deleted_at => nil}
    base.has_many :fiscal_org_owner_grants, :class_name => 'Request', :foreign_key => :fiscal_org_owner_id, :conditions => {:granted => 1, :deleted_at => nil}
    base.has_many :fiscal_signatory_grants, :class_name => 'Request', :foreign_key => :fiscal_signatory_id, :conditions => {:granted => 1, :deleted_at => nil}
    base.has_many :role_users_programs, :class_name => 'RoleUser', :foreign_key => 'user_id'
    base.has_many :role_programs, :class_name => 'Program', :through => :role_users_programs, :source => :user
    
    base.send :attr_accessor, :temp_organization_title
    base.send :attr_accessor, :temp_organization_id
    
    # TODO ESH: find a way to reference related requests based on a conditional join
    # base.has_many :related_requests, :class_name => 'Request', :conditions => 

    base.send :include, ::FluxxUser
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES + [:group_ids, :was_grantee_org_owner]
      insta.derived_filters = {
        :grant_program_ids => (lambda do |search_with_attributes, request_params, name, val|
          program_id_strings = val
          programs = Program.where(:id => program_id_strings).all.compact
          program_ids = programs.map do |program| 
            children = program.children_programs
            programs = if children.empty?
              [program]
            else
              [program] + children
            end
            programs << program.parent_program if program.parent_program
            programs
          end.compact.flatten.map &:id
          if program_ids && !program_ids.empty?
            search_with_attributes[:grant_program_ids] = program_ids
          end
        end),
      }
    end
    base.insta_realtime do |insta|
      insta.delta_attributes = SEARCH_ATTRIBUTES
      insta.updated_by_field = :updated_by_id
    end
    base.insta_export do |insta|
      insta.filename = 'user'
      insta.headers = [['Date Created', :date], ['Date Updated', :date], 'salutation', 'first_name', 'last_name', 'email', 'personal_email', 'prefix', 'middle_initial', 'personal_phone', 
                      'personal_mobile', 'personal_fax',
                      'personal_street_address', 'personal_street_address2', 'personal_city', 'state_name', 'country_name', 'personal_postal_code', 'work_street_address', 'work_street_address2', 
                      'work_city', 'work_state', 'work_country', 'work_postal_code', 'work_phone', 'work_fax', 'other_contact',
                      'assistant_name', 'assistant_email', 'blog_url', 'twitter_url', ['Birthday', :date], 'primary_title', 'primary_organization', 'time_zone']
      insta.sql_query = "users.created_at, users.updated_at, salutation, first_name, last_name, users.email, personal_email, prefix, middle_initial, personal_phone, personal_mobile, personal_fax,
                      personal_street_address, personal_street_address2, personal_city, geo_states.name state_name,  geo_countries.name country_name, personal_postal_code, 
                      organizations.street_address work_street_address, organizations.street_address2 work_street_address2, organizations.city work_city,
                      work_geo_states.name work_state_name, work_countries.name work_country_name, organizations.postal_code work_postal_code,
                      work_phone, work_fax, users.other_contact, 
                      assistant_name, assistant_email, users.blog_url, users.twitter_url, birth_at, 
                      user_organizations.title organization_title, organizations.name primary_organization, time_zone
                      from users 
                      left outer join geo_states on geo_states.id = personal_geo_state_id
                      left outer join geo_countries on geo_countries.id = personal_geo_country_id
                      left outer join user_organizations on user_organizations.id = primary_user_organization_id
                      left outer join organizations on organizations.id = user_organizations.organization_id
                      left outer join geo_states as work_geo_states on work_geo_states.id = organizations.geo_state_id
                      left outer join geo_countries as work_countries on work_countries.id = organizations.geo_country_id
                      where users.id IN (?)"
    end
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    
    base.add_sphinx if base.respond_to?(:sphinx_indexes) && !(base.connection.adapter_name =~ /SQLite/i)
  end

  module ModelClassMethods
    def add_sphinx
      define_index :user_first do
        # fields
        indexes "lower(users.first_name)", :as => :first_name, :sortable => true
        indexes "lower(users.last_name)", :as => :last_name, :sortable => true
        indexes "lower(users.email)", :as => :email, :sortable => true
        indexes "lower(TRIM(CONCAT(CONCAT(IFNULL(users.first_name, ' '), ' '), IFNULL(users.last_name, ' '))))", :as => :full_name, :sortable => true

        # attributes
        has created_at, updated_at, deleted_at, test_user_flag
        
        has role_users_programs.program(:id), :as => :grant_program_ids
        has 'null', :type => :multi, :as => :grant_sub_program_ids

        has 'null', :type => :multi, :as => :favorite_user_ids
        has 'null', :type => :multi, :as => :organization_id
        has 'null', :type => :multi, :as => :user_profile_id
        has 'null', :type => :multi, :as => :last_name_ord
        has 'null', :type => :multi, :as => :first_name_ord
        has request_users.request(:id), :type => :multi, :as => :user_request_ids
        has 'null', :type => :multi, :as => :group_ids
        has grantee_org_owner_grants(:id), :type => :multi, :as => :org_owner_grant_ids
        has 'count(grantee_org_owner_grants_users.id) > 1', :type => :boolean, :as => :was_grantee_org_owner
        set_property :delta => :delayed
      end

      define_index :user_second do
        # fields
        indexes "lower(users.first_name)", :as => :first_name, :sortable => true
        indexes "lower(users.last_name)", :as => :last_name, :sortable => true
        indexes "lower(users.email)", :as => :email, :sortable => true
        indexes "lower(TRIM(CONCAT(CONCAT(IFNULL(users.first_name, ' '), ' '), IFNULL(users.last_name, ' '))))", :as => :full_name, :sortable => true

        # attributes
        has created_at, updated_at, deleted_at, test_user_flag

        has 'null', :type => :multi, :as => :grant_program_ids
        has 'null', :type => :multi, :as => :grant_sub_program_ids

        has favorites.user(:id), :as => :favorite_user_ids
        has user_organizations.organization(:id), :as => :organization_id
        has user_profile_id
        has '((ORD(LOWER(SUBSTRING(users.last_name,1,1))) * 16777216) + (ORD(LOWER(SUBSTRING(users.last_name,2,1))) * 65536) +
        (ORD(LOWER(SUBSTRING(users.last_name,3,1))) * 256) + (ORD(LOWER(SUBSTRING(users.last_name,4,1)))))', :type => :multi, :as => :last_name_ord
        has '((ORD(LOWER(SUBSTRING(users.first_name,1,1))) * 16777216) + (ORD(LOWER(SUBSTRING(users.first_name,2,1))) * 65536) +
        (ORD(LOWER(SUBSTRING(users.first_name,3,1))) * 256) + (ORD(LOWER(SUBSTRING(users.first_name,4,1)))))', :type => :multi, :as => :first_name_ord
        has 'null', :type => :multi, :as => :user_request_ids
        has group_members.group(:id), :type => :multi, :as => :group_ids
        has grantee_org_owner_grants(:id), :type => :multi, :as => :org_owner_grant_ids
        has 'count(requests.id) > 1', :type => :boolean, :as => :was_grantee_org_owner
        set_property :delta => :delayed
      end
    end
  end

  module ModelInstanceMethods
    def all_related_requests
      Request.where(:id => request_ids).all
    end
    
    def request_ids
      Request.select(:id).where(:deleted_at => nil).where(['program_lead_id = ? OR fiscal_org_owner_id = ? OR grantee_signatory_id = ? OR fiscal_signatory_id = ? OR grantee_org_owner_id = ?', self.id, self.id, self.id, self.id, self.id]).map &:id
    end
    
    def related_requests look_for_granted=false, limit_amount=20
      granted_param = look_for_granted ? 1 : 0
      Request.find_by_sql ["SELECT requests.* 
        FROM requests 
        WHERE deleted_at IS NULL AND id IN (?)  AND granted = ?
        UNION
        SELECT requests.*
        FROM requests, request_users
        WHERE deleted_at IS NULL AND requests.id = request_users.request_id AND request_users.user_id = ? AND granted = ?
        GROUP BY requests.id
        ORDER BY grant_agreement_at desc, request_received_at desc
        limit ?
        ", request_ids, granted_param, self.id, granted_param, limit_amount]
    end
    
    def is_grantee?
      has_named_user_profile? 'Grantee'
    end

    def is_reviewer?
      has_named_user_profile? 'Reviewer'
    end

    def is_portal_user?
      is_grantee? || is_reviewer?
    end
    
    def related_grants limit_amount=20
      related_requests true, limit_amount
    end
    
    def related_organizations limit_amount=20
      organizations.order('name asc').limit(limit_amount)
    end
    
    def program_ids
      role_programs.map &:id
    end

    def grant_program_ids
     all_related_requests.map{|req| req.program.id if req && req.program}.flatten.compact
    end

    def grant_sub_program_ids
      all_related_requests.map{|req| req.sub_program.id if req && req.sub_program}.flatten.compact
    end

    def organization_id
     user_organizations.map{|uo| uo.organization.id if uo.organization}.flatten.compact
    end
    def program_ids_by_role role
      program_ids = role_users.joins(:role).where(:roles => {:roleable_type => "Program", :name => role}).all.map {|ru| ru.roleable_id }
      Program.find(:all, :conditions => ['id in (?) OR parent_id in (?)', program_ids, program_ids]).map{|program| program.id}.compact
    end
  end
end