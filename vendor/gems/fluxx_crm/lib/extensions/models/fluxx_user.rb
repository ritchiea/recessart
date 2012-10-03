require 'net/ldap'
module FluxxUser
  include ::URLCleaner
  SEARCH_ATTRIBUTES = [:state, :updated_at, :first_name, :last_name]
  LIQUID_METHODS = [:salutation, :full_name, :first_name, :last_name, :title, :main_phone, :email, :work_phone, :work_fax, :primary_user_organization]  

  def self.included(base)
    base.has_many :user_organizations
    base.has_many :organizations, :through => :user_organizations
    base.belongs_to :personal_geo_country, :class_name => 'GeoCountry', :foreign_key => :personal_geo_country_id
    base.belongs_to :personal_geo_state, :class_name => 'GeoState', :foreign_key => :personal_geo_state_id
    base.belongs_to :primary_user_organization, :class_name => 'UserOrganization', :foreign_key => :primary_user_organization_id
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :user_profile
    if User.columns.map(&:name).include?('client_id')
      base.belongs_to :client 
    else
      base.send :attr_accessor, :client
    end
    base.has_many :model_documents, :as => :documentable
    base.has_many :notes, :as => :notable, :conditions => {:deleted_at => nil}
    base.has_many :group_members, :as => :groupable
    base.has_many :groups, :through => :group_members
    base.has_many :role_users
    base.has_many :roles, :through => :role_users
    base.has_many :user_permissions
    base.has_many :bank_accounts, :foreign_key => :owner_user_id
    base.acts_as_audited({:full_model_enabled => false, :except => [:activated_at, :created_by_id, :updated_by_id, :updated_by, :created_by, :audits, :role_users, :locked_until, :locked_by_id, :delta, :crypted_password, :password, :last_logged_in_at]})
    base.before_save :preprocess_user
    
    
    base.acts_as_authentic do |c|
      # c.my_config_option = my_value # for available options see documentation in: Authlogic::ActsAsAuthentic
      c.act_like_restful_authentication = true
      c.validate_login_field=false
      c.validate_password_field=false
      c.validate_email_field=false
    end # block optional
    

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end

    base.insta_realtime do |insta|
      insta.delta_attributes = SEARCH_ATTRIBUTES
      insta.updated_by_field = :updated_by_id
    end
    base.insta_multi
    base.insta_export
    base.insta_lock
    
    base.validates_presence_of     :first_name
    base.validates_presence_of     :last_name

    base.validates_length_of       :email,    :within => 6..250, :if => lambda {|user| !user.email.blank? }
    base.validates_uniqueness_of   :email, :if => lambda {|user| !user.email.blank? }, :scope => [:deleted_at]

    base.validates_length_of       :login,    :within => 6..40, :if => lambda {|user| !user.login.blank? }
    base.validates_uniqueness_of   :login, :if => lambda {|user| !user.login.blank? }, :scope => [:deleted_at]
    
    base.insta_utc do |insta|
      insta.time_attributes = [:birth_at]
    end  
    base.insta_favorite
    
    base.insta_template do |insta|
      insta.entity_name = 'user'
      insta.add_methods [:full_name, :main_phone]
      insta.remove_methods [:id]
    end
    base.liquid_methods *( LIQUID_METHODS )    

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    
    # ESH: hack to rename User to Person
    def model_name
      u = ActiveModel::Name.new User
      u.instance_variable_set '@human', 'Person'
      u
    end
    
    def document_title_name
      'Person'
    end
    
    def employees
      user_profile = UserProfile.where(:name => 'employee').first
      if user_profile
        User.where(:user_profile_id => user_profile.id, :deleted_at => nil, :test_user_flag => false).order('first_name asc, last_name asc').all
      end || []
    end
    
    def users_with_profile profile_name
      if profile_name && (user_profile = UserProfile.all_user_profile_map_by_name[profile_name])
        User.where(:user_profile_id => user_profile.id, :deleted_at => nil, :test_user_flag => false).order('first_name asc, last_name asc').all
      end || []
    end
    
    # Tries to find a User first by looking into the database and then by creating a User if there's an LDAP entry for the given login
    def find_or_create_from_ldap(login)
      find_by_login(login) || create_from_ldap_if_valid(login)
    end  

    ######################################### LDAP
    # Creates a User record in the database if there is an entry in LDAP with the given login
    def create_from_ldap_if_valid(login)
      return nil unless Fluxx.config(:ldap_enabled) == "1"
      ldap_user = User.ldap_find(login)
      if ldap_user
        return User.create_or_update_user_from_ldap_entry(login, ldap_user)
      end
      nil
    end

    def ldap_find(login)
      return nil unless Fluxx.config(:ldap_enabled) == "1"
      # see http://net-ldap.rubyforge.org/Net/LDAP.html
      ldap = Net::LDAP.new
      ldap.host = LDAP_CONFIG[:host]
      ldap.port = LDAP_CONFIG[:port]
      ldap.base = LDAP_CONFIG[:base]
      ldap.encryption LDAP_CONFIG[:encryption] if LDAP_CONFIG[:encryption]
      ldap.auth LDAP_CONFIG[:bind_dn], LDAP_CONFIG[:password]
      filter = Net::LDAP::Filter.eq(LDAP_CONFIG[:login_attr], login) 
      results = ldap.search(:filter => filter) 
      results.each do |entry|
        logger.info "FOUND IN LDAP:  #{login}"
        return entry
      end
      logger.info { "NOT FOUND IN LDAP:  #{login}" }
      nil
    end    
    
    def create_or_update_user_from_ldap_entry(login, entry)
      user = User.find_by_login login
      user = User.new(:login => login) unless user
      logger.info "#{user.new_record? ? 'Creating' : 'Updating'} user from ldap entry: #{login}"
      user.first_name = entry[LDAP_CONFIG[:first_name_attr]].first
      user.last_name  = entry[LDAP_CONFIG[:last_name_attr]].first
      user.email      = entry[LDAP_CONFIG[:email_attr]].first
      user.user_profile = UserProfile.find_by_name 'employee' if user.new_record?
      user.save
      logger.info { "user.errors = #{user.errors.inspect}" }
      return user
    end
  end

  module ModelInstanceMethods
    def login=(value)
      write_attribute :login, (value.blank? ? nil : value)
    end

    def email=(value)
      write_attribute :email, (value.blank? ? nil : value)
    end
    
    def main_phone
      work = self.work_phone
      org = primary_user_organization && primary_user_organization.organization ? primary_user_organization.organization.phone : nil
      mobile = self.personal_mobile
      work || org || mobile
    end

    def main_fax
      work = self.work_fax
      org = primary_user_organization && primary_user_organization.organization ? primary_user_organization.organization.fax : nil
      work || org
    end
    
    def preprocess_user
      self.login = nil if login == ''
    end
    
    def before_create
      self.blog_url = clean_url(self.blog_url)
    end
    def before_update
      self.blog_url = clean_url(self.blog_url)
    end
    def merge dup
      unless dup.nil? || self == dup
        User.transaction do
          merge_associations dup
          dup.destroy
        end
      end
    end

    # In the implementation, you can override this method or alias_method_chain to put it aside and call it as well 
    def merge_associations dup
      my_role_users = RoleUser.joins(:role).where(:user_id => self.id).all
      RoleUser.joins(:role).where(:user_id => dup.id).all.each do |ru|
        existing_ru = my_role_users.select {|mru| mru.role.name == ru.role.name && mru.roleable_id == ru.roleable_id}
        ru.destroy unless existing_ru.empty?
      end
      
      [Audit, ClientStore, Favorite, RealtimeUpdate, RoleUser].each do |aclass|
        aclass.update_all ['user_id = ?', self.id], ['user_id = ?', dup.id]
      end

      GroupMember.update_all ['groupable_id = ?', self.id], ['groupable_id = ? and groupable_type = ?', dup.id, User.name]
      GroupMember.update_all ['created_by_id = ?', self.id], ['created_by_id = ?', dup.id]
      GroupMember.update_all ['updated_by_id = ?', self.id], ['updated_by_id = ?', dup.id]

      # Kill the primary_user_organization_id for this user
      dup.update_attribute :primary_user_organization_id, nil

      User.connection.execute 'DROP TABLE IF EXISTS dupe_user_orgs'
      User.connection.execute User.send(:sanitize_sql, ['CREATE TEMPORARY TABLE dupe_user_orgs AS SELECT organization_id, COUNT(*) tot 
          FROM user_organizations WHERE user_id IN (?) GROUP BY organization_id', [self.id]])
      User.connection.execute User.send(:sanitize_sql, ['DELETE FROM user_organizations 
          WHERE user_id = ? AND user_organizations.organization_id IN (select organization_id from dupe_user_orgs)', dup.id])
      UserOrganization.update_all ['user_id = ?', self.id], ['user_id = ?', dup.id] # Now take care of the rest of the user orgs

      [UserOrganization, Note, Organization, User, ModelDocument, Group].each do |aclass|
        aclass.update_all ['created_by_id = ?', self.id], ['created_by_id = ?', dup.id]
        aclass.update_all ['updated_by_id = ?', self.id], ['updated_by_id = ?', dup.id]
        unless aclass == Note || aclass == GroupMember || aclass == Group # not lockable
          aclass.update_all 'locked_by_id = null, locked_until = null', ['locked_by_id = ?', dup.id]
        end
      end

      # Need to be sure for our polymorphic relations that we're covered
      Note.update_all ['notable_id = ?', self.id], ['notable_type = ? AND notable_id = ?', 'User', dup.id]

      Favorite.update_all ['favorable_id = ?', self.id], ['favorable_type = ? AND favorable_id = ?', 'User', dup.id]
    end
    
    ######################################### ROLES
    def add_role role_name, related_object = nil
      role = if related_object
        related_object_class = related_object.is_a?(Class) ? related_object : related_object.class
        Role.where(:name => role_name, :roleable_type => related_object_class.name).first || Role.create(:name => role_name, :roleable_type => related_object_class.name)
      else
        Role.where(:name => role_name).first || Role.create(:name => role_name)
      end
      if related_object
        role_users.create :role_id => role.id, :roleable_id => related_object.id if role
      else
        role_users.create :role_id => role.id if role
      end
    end
    
    def remove_role role_name, related_object = nil
      role_user = has_role? role_name, related_object
      role_user.destroy if role_user
    end
    
    # Includes a device to map related_objects to their parents, so if a user does not have a relationship to the related_object, they may have one to the parent
    def has_role_user? role_name, related_object = nil
      return true if is_admin?
      if related_object
        roles = role_users.joins(:role).where(:roleable_id => related_object.id, :roles => {:roleable_type => related_object.class.name, :name => role_name}).all
        roles = role_users.joins(:role).where(:roleable_id => related_object.parent_id, :roles => {:roleable_type => related_object.class.name, :name => role_name}).all if roles.empty? && related_object.respond_to?('parent_id')
        roles
      else
        role_users.joins(:role).where(:roles => {:name => role_name})
      end.first
    end
    
    # Add a role if none exists; if related_object is a class, generated a role_name that includes the class
    def has_role! role_name, related_object = nil, remove_role=false
      role = has_role?(role_name, related_object)

      if remove_role
        role.destroy
      else
        if role
          role
        else
          role = add_role role_name, related_object
        end
      end
    end
    
    def clear_role role_name, related_object = nil
      has_role! role_name, related_object, true
    end
    
    # Check for a role associated with this user
    def has_role? role_name, related_object = nil
      return true if is_admin?
      has_role_user?(role_name, related_object)
    end

######################################### PERMISSIONS

    def add_permission permission_name, related_object = nil
      if related_object
        user_permissions.create :name => permission_name, :model_type => derive_class_name(related_object) if related_object
      else
        user_permissions.create :name => permission_name
      end
    end

    def remove_permission permission_name, related_object = nil
      user_permission = has_permission? permission_name, related_object
      user_permission.destroy if user_permission
    end
    
    def all_user_permissions
      @cached_all_user_permissions = UserPermission.all unless @cached_all_user_permissions
      @cached_all_user_permissions
    end

    # Includes a device to map related_objects to their parents, so if a user does not have a relationship to the related_object, they may have one to the parent
    def has_user_permission? permission_name, related_object = nil
      # Load up all user_permissions
      
      if related_object
        user_permissions.where(:model_type => derive_class_name(related_object), :name => permission_name).all
      else
        user_permissions.where(:name => permission_name).all
      end.first
    end

    # Add a permission if none exists
    def has_permission! permission_name, related_object = nil, remove_permission=false
      permission = has_permission? permission_name, derive_class_name(related_object)
      if remove_permission
        permission.destroy
      else
        if permission
          permission
        else
          permission = add_permission permission_name, related_object
        end
      end
    end
    
    def derive_class_name related_object
      if related_object.is_a? Class
        related_object.name
      elsif related_object.is_a? String
        related_object
      elsif related_object
        related_object.class.name
      end
    end

    def clear_permission permission_name, related_object = nil
      has_permission! permission_name, related_object, true
    end

    # Check for either a simple permission or a profile rule for the permission associated with this user
    # always_return_object says that if a user_profile_rule is found (and not a user_permission), return the rule that was found.  This is because sometimes a rule will be present and be marked not allowed
    def has_permission? permission_name, related_object = nil, always_return_object=false
      user_profile_permission = self.user_profile_include?(permission_name, related_object)
      has_user_permission?(permission_name, related_object) || (always_return_object ? user_profile_permission : (user_profile_permission && user_profile_permission.allowed?))
    end
    
    # Check to see if this users profile includes the permission_name
    def user_profile_include? permission_name, related_object = nil
      if user_profile_id && UserProfile.all_user_profile_map[user_profile_id]
        UserProfile.all_user_profile_map[user_profile_id].has_rule?(permission_name, derive_class_name(related_object))
      end
    end
    
    def user_related_to_model? model
      (model.respond_to?(:relates_to_user?) && model.relates_to_user?(self))
    end

    def is_admin?
      self.has_permission?('admin')
    end
    
    # permission_name: name of permission to check for this user
    # model: accept either a class, string or model
    def has_permission_for_object? permission_name, model
      cur_model = if model.is_a? Class
        model
      elsif model.is_a? String
        model
      else
        model.class
      end
      permission_found = false
      while cur_model && !permission_found
        permission_found = has_permission?(permission_name, cur_model, true)
        if cur_model.is_a? Class
          cur_model = cur_model.superclass
          cur_model = nil if cur_model == ActiveRecord::Base || cur_model == Object
        else
          cur_model = nil
        end
      end

      if permission_found && permission_found.is_a?(UserProfileRule)
        permission_found.allowed
      elsif permission_found
        permission_found
      elsif ['create', 'update', 'delete', 'view', 'listview'].include? permission_name.to_s
        has_permission?("create_all")
      else
        permission_found
      end
    end

    def has_create_for_own_model? model_class
      has_permission_for_object?("create_own", model_class)
    end
    
    def has_create_for_model? model_class
      is_admin? || has_permission_for_object?("create", model_class) || has_create_for_own_model?(model_class)
    end
    
    def has_update_for_own_model? model
      has_permission_for_object?("update_own", model) && user_related_to_model?(model)
    end

    def has_update_for_model? model_class
      is_admin? || has_permission_for_object?("update", model_class) || has_update_for_own_model?(model_class)
    end
    
    def has_delete_for_own_model? model
      has_permission_for_object?("delete_own", model) && user_related_to_model?(model)
    end

    def has_delete_for_model? model_class
      is_admin? || has_permission_for_object?("delete", model_class)  || has_delete_for_own_model?(model_class)
    end
    
    def has_listview_for_model? model_class
      is_admin? || has_permission_for_object?("listview", model_class)
    end
    
    def has_view_for_own_model? model
      has_permission_for_object?("view_own", model) && user_related_to_model?(model)
    end

    def has_view_for_model? model_class
      is_admin? || has_permission_for_object?("view", model_class) || has_view_for_own_model?(model_class)
    end
    
    def has_named_user_profile? name
      user_profile = UserProfile.all_user_profile_map_by_name[name]
      user_profile && self.user_profile_id == user_profile.id
    end
    
    def is_employee?
      has_named_user_profile? 'Employee'
    end

    def is_board_member?
      has_named_user_profile? 'Board'
    end

    def is_consultant?
      has_named_user_profile? 'Consultant'
    end

    def full_name
      [first_name, last_name].join ' '
    end
    
    def to_s
      full_name
    end
    
    def title
      primary_user_organization ? primary_user_organization.title : ''
    end
    
    def primary_organization
      primary_user_organization.organization if primary_user_organization
    end
    
    def mailer_email
      "#{full_name} <#{email}>"
    end
    
    ######################################### AUTHLOGIC / LDAP
    
    # check ldap credentials(and sync info), or db credentials(normal authlogic pw check)
    def valid_credentials?(password)
      ldap_authenticate?(password) || valid_password?(password)
    end

    def ldap_authenticate?(password)
      return false unless Fluxx.config(:ldap_enabled) == "1"
      return false unless login.present?
      
      ldap = Net::LDAP.new
      ldap.host = LDAP_CONFIG[:host]
      ldap.port = LDAP_CONFIG[:port]
      ldap.base = LDAP_CONFIG[:base]
      ldap.encryption LDAP_CONFIG[:encryption] if LDAP_CONFIG[:encryption]
      ldap.auth LDAP_CONFIG[:bind_dn], LDAP_CONFIG[:password]
      filter = Net::LDAP::Filter.eq(LDAP_CONFIG[:login_attr], login) 
      begin
        result = ldap.bind_as(:filter => filter, :password => password)
        if result
          logger.info "LDAP Authentication SUCCESSFUL for: #{login}"
          User.create_or_update_user_from_ldap_entry(login, result.first)
          return true
        else
          logger.info "LDAP Authentication FAILED for: #{login}"
        end    
      rescue Exception => e
      end
      false
    end
  end
end
