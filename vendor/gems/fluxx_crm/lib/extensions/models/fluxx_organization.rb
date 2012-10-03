module FluxxOrganization
  include ::URLCleaner
  SEARCH_ATTRIBUTES = [:state, :created_at, :updated_at, :name, :id]
  LIQUID_METHODS = [:name, :display_name, :street_address, :street_address2, :city, :state_name, :state_abbreviation, :postal_code, :country_name, :url, :acronym, :bank_accounts, :tax_id, :tax_class_name]  
  
  def self.included(base)
    base.has_many :user_organizations
    base.has_many :users, :through => :user_organizations
    base.belongs_to :parent_org, :class_name => 'Organization', :foreign_key => :parent_org_id
    base.has_many :satellite_orgs, :class_name => 'Organization',  :foreign_key => :parent_org_id, :conditions => {:deleted_at => nil}
    base.belongs_to :geo_country
    base.belongs_to :geo_state
    base.has_many :model_documents, :as => :documentable
    base.has_many :notes, :as => :notable, :conditions => {:deleted_at => nil}
    base.has_many :group_members, :as => :groupable
    base.has_many :groups, :through => :group_members
    base.has_many :bank_accounts, :foreign_key => :owner_organization_id
    base.after_save :rename_satellites

    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.scope :hq, :conditions => 'organizations.parent_org_id IS NULL'
    base.send :attr_accessor, :force_headquarters
    base.after_save :update_satellite_preference
    
    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})

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

    base.insta_template do |insta|
      insta.entity_name = 'organization'
      insta.add_methods [:geo_country, :geo_state]
      insta.remove_methods [:id]
    end
    base.liquid_methods *( LIQUID_METHODS )  

    base.validates_presence_of     :name
    base.validates_length_of       :name,    :within => 3..255
    base.insta_favorite
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end
  

  module ModelClassMethods
    def document_title_name
      I18n.t(:Organization)
    end

    # ESH: hack to handle case of Organisation / Organization
    def model_name
      u = ActiveModel::Name.new Organization
      u.instance_variable_set '@human', I18n.t(:Organization)
      u
    end

    def current_grantor
      where(:is_grantor => true).first
    end
  end
  
  module ModelInstanceMethods
    def before_create
      self.url      = clean_url(self.url)
      self.blog_url = clean_url(self.blog_url)
    end
    def before_update
      self.url = clean_url(self.url)
      self.blog_url = clean_url(self.blog_url)
    end
  
    def geo_country= val
      if val.is_a? GeoCountry
        write_attribute(:geo_country, val) 
      elsif
        write_attribute(:geo_country, GeoCountry.find_by_name(val))
      end
    end

    def geo_state= val
      if val.is_a? GeoState
        write_attribute(:geo_state, val) 
      elsif
        write_attribute(:geo_state, GeoState.find_by_name(val))
      end
    end
    
    def autocomplete_to_s
      if is_headquarters?
        "#{name} - headquarters"
      else
        "#{name} - #{[street_address, city].compact.join ', '}"
      end
    end
  
    def is_headquarters?
      parent_org_id == nil
    end
    
    def display_name
      name
    end
    
    def satellites
      Organization.where(:id => related_ids).all
    end
  
    def satellite_ids
      Organization.find(:all, :select => :id, :conditions => {:parent_org_id => self.id}).map(&:id)
    end
  
    def related_ids
      [self.id] + satellite_ids
    end
    
    def related_users limit_amount=20
      users.where(:deleted_at => nil).order('last_name asc, first_name asc').limit(limit_amount)
    end

    def has_satellites?
      is_headquarters? && Organization.find(id, :select => "(select count(*) from organizations sat where sat.parent_org_id = organizations.id) satellite_count").satellite_count.to_i
    end
  
    def is_satellite?
      parent_org_id != nil
    end
  
    def state_name
      geo_state.name if geo_state
    end
    
    def state_abbreviation
      geo_state.abbreviation if geo_state
    end
  
    def country_name
      geo_country.name if geo_country
    end

    def tax_class_name
      tax_class.name if tax_class
    end

  
    def to_s
      name.blank? ? nil : name
    end
  
    def merge dup
      unless dup.nil? || self == dup
        Organization.transaction do
          merge_associations dup
        
          # finally remove duplicate
          dup.destroy
        end
      end
    end
  
    # In the implementation, you can override this method or alias_method_chain to put it aside and call it as well 
    def merge_associations dup
      User.connection.execute 'DROP TABLE IF EXISTS dupe_user_orgs'
      User.connection.execute User.send(:sanitize_sql, ['CREATE TEMPORARY TABLE dupe_user_orgs AS SELECT organization_id, COUNT(*) tot 
          FROM user_organizations WHERE organization_id IN (?) GROUP BY user_id', [self.id]])
      User.connection.execute User.send(:sanitize_sql, ['DELETE FROM user_organizations 
          WHERE organization_id = ? AND user_organizations.organization_id IN (select organization_id from dupe_user_orgs)', dup.id])
      UserOrganization.update_all ['organization_id = ?', self.id], ['organization_id = ?', dup.id] # Now take care of the rest of the user orgs
      
      Organization.update_all ['parent_org_id = ?', id], ['parent_org_id = ?', dup.id]
    
      # Need to be sure for our polymorphic relations that we're covered
      Note.update_all ['notable_id = ?', self.id], ['notable_type = ? AND notable_id = ?', 'Organization', dup.id]
      Favorite.update_all ['favorable_id = ?', self.id], ['favorable_type = ? AND favorable_id = ?', 'Organization', dup.id]
    end
  end
  
  def rename_satellites
    # If this org has been updated and has satellites, need to synchronize the name
    satellites.each do |sat|
      sat.update_attributes :name => self.name unless sat.name == self.name
    end
  end
  
  def realtime_update_id
    parent_org_id ? parent_org_id : id
  end
  
  def update_satellite_preference
    if self.force_headquarters == '1'
      self.force_headquarters = nil # Very important to nil this out, or we could have ourselves an infinite loop on our hands
      if parent_org
        parent_satellites = parent_org.satellites
        parent_satellites.each {|sat_org| sat_org.update_attributes :parent_org_id => self.id}
        parent_org.update_attributes :parent_org_id => self.id
        self.update_attributes :parent_org_id => nil
      end
    end
  end
end
