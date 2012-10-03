module FluxxRequestTransaction
  def self.prepare_from_date search_with_attributes, name, val
    if (Time.parse(val) rescue nil)
      start_at = Time.parse(val)
      if search_with_attributes[name] && search_with_attributes[name].end < FAR_IN_THE_FUTURE.to_i
        search_with_attributes[name] = (start_at.to_i..(search_with_attributes[name].end))
      else
        search_with_attributes[name] = (start_at.to_i..FAR_IN_THE_FUTURE.to_i)
      end
      search_with_attributes
    end || {}
  end
  
  def self.prepare_to_date search_with_attributes, name, val
    if (Time.parse(val) rescue nil)
      end_at = Time.parse(val)
      if search_with_attributes[name] && search_with_attributes[name].begin > 0
        search_with_attributes[name] = ((search_with_attributes[name].begin)..end_at.to_i)
      else
        search_with_attributes[name] = (0..end_at.to_i)
      end
      search_with_attributes
    end || {}
  end

  SEARCH_ATTRIBUTES = [:grant_program_ids, :grant_sub_program_ids, :state, :updated_at, :request_type, :amount_paid, :favorite_user_ids, :has_been_paid, :filter_state, :request_hierarchy, :allocation_hierarchy]
  FAR_IN_THE_FUTURE = Time.now + 1000.year
  LIQUID_METHODS = [:amount_due, :due_at, :condition, :paid_at, :amount_paid]
  
  def self.included(base)
    base.belongs_to :request
    base.belongs_to :grant, :class_name => 'Request', :foreign_key => 'request_id', :conditions => {:granted => 1}
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :payment_recorded_by, :class_name => 'User', :foreign_key => 'payment_recorded_by_id'
    base.belongs_to :user_payee, :class_name => 'User', :foreign_key => 'user_payee_id'
    base.belongs_to :organization_payee, :class_name => 'Organization', :foreign_key => 'organization_payee_id'
    base.has_many :request_transaction_funding_sources
    base.has_many :workflow_events, :as => :workflowable
    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :modified_by_id, :locked_until, :locked_by_id, :delta, :updated_by, :created_by, :audits]})
    base.has_many :model_documents, :as => :documentable
    base.has_many :notes, :as => :notable, :conditions => {:deleted_at => nil}
    base.has_many :group_members, :as => :groupable
    base.has_many :groups, :through => :group_members
    base.send :attr_accessor, :organization_lookup
    base.belongs_to :bank_account
    base.send :attr_accessor, :request_transaction_funding_source_param_hash
    base.send :attr_accessor, :using_transaction_form
    base.validate :validate_required_funding_source, :if => Proc.new{|model| !model.new_record?}
    base.after_save :update_rtfs
    base.after_create :update_state_by_payment_type
    base.after_save :update_state_by_payment_type
    
    base.insta_favorite
    base.insta_export do |insta|
      insta.filename = 'request_transaction'
      insta.headers = [['Date Created', :date], ['Date Updated', :date], 'request_id', ['Amount Paid', :currency], ['Amount Due', :currency], ['Date Due', :date], ['Date Paid', :date], 'payment_type', 'payment_confirmation', 'Comment', 'Status',
        'Grantee', 'Grantee Street Address', 'Grantee Street Address2', 'Grantee City', 'Grantee State', 'Grantee Country', 'Grantee Postal Code', 'Grantee URL',
        'Fiscal Org', 'Fiscal Street Address', 'Fiscal Street Address2', 'Fiscal City', 'Fiscal State', 'Fiscal Country', 'Fiscal Postal Code', 'Fiscal URL']
      insta.sql_query = "request_transactions.created_at, request_transactions.updated_at, requests.base_request_id request_id, amount_paid, amount_due, due_at, paid_at, payment_type, payment_confirmation_number,
                request_transactions.comment,
                request_transactions.state, 
                program_organization.name,
                program_organization.street_address program_org_street_address, program_organization.street_address2 program_org_street_address2, program_organization.city program_org_city,
                program_org_country_states.name program_org_state_name, program_org_countries.name program_org_country_name, program_organization.postal_code program_org_postal_code,
                program_organization.url program_org_url,
                fiscal_organization.name,
                fiscal_organization.street_address fiscal_org_street_address, fiscal_organization.street_address2 fiscal_org_street_address2, fiscal_organization.city fiscal_org_city,
                fiscal_org_country_states.name fiscal_org_state_name, fiscal_org_countries.name fiscal_org_country_name, fiscal_organization.postal_code fiscal_org_postal_code,
                fiscal_organization.url fiscal_org_url
              from request_transactions
              left outer join requests on request_transactions.request_id = requests.id
              LEFT OUTER JOIN organizations program_organization ON program_organization.id = requests.program_organization_id
              LEFT OUTER JOIN organizations fiscal_organization ON fiscal_organization.id = requests.fiscal_organization_id
              left outer join geo_states as program_org_country_states on program_org_country_states.id = program_organization.geo_state_id
              left outer join geo_countries as program_org_countries on program_org_countries.id = program_organization.geo_country_id
              left outer join geo_states as fiscal_org_country_states on fiscal_org_country_states.id = fiscal_organization.geo_state_id
              left outer join geo_countries as fiscal_org_countries on fiscal_org_countries.id = fiscal_organization.geo_country_id
              where request_transactions.id IN (?)"
    end
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES  + [:group_ids, :due_within_days, :overdue_by_days, :lead_user_ids, :grant_multi_element_value_ids, :request_from_date, :request_to_date, :funding_source_allocation_id, :request_hierarchy, :allocation_hierarchy]
      insta.derived_filters = {:due_within_days => (lambda do |search_with_attributes, request_params, name, value|
        value = value.first if value && value.is_a?(Array)
          if value.to_s.is_numeric?
            due_date_check = Time.now + value.to_i.days
            search_with_attributes[:due_at] = (Time.now.to_i..due_date_check.to_i)
            search_with_attributes[:has_been_paid] = false
          end || {}
        end),
        :request_hierarchy => (lambda do |search_with_attributes, request_params, name, val|
          FluxxGrantSphinxHelper.prepare_hierarchy search_with_attributes, name, val
        end),
        :allocation_hierarchy => (lambda do |search_with_attributes, request_params, name, val|
          FluxxGrantSphinxHelper.prepare_hierarchy search_with_attributes, name, val
        end),
        :overdue_by_days => (lambda do |search_with_attributes, request_params, name, value|
          value = value.first if value && value.is_a?(Array)
          if value.to_s.is_numeric?
            due_date_check = Time.now - value.to_i.days
            search_with_attributes[:due_at] = (0..due_date_check.to_i)
            search_with_attributes[:has_been_paid] = false
          end || {}
        end),
        :request_from_date => (lambda do |search_with_attributes, request_params, name, val|
          val = val.first if val && val.is_a?(Array)
          date_range_selector = request_params[:request_transaction][:date_range_selector] if request_params[:request_transaction]
          date_range_selector = request_params[:date_range_selector] unless date_range_selector
          case date_range_selector
          when 'due_at' then
            prepare_from_date search_with_attributes, :due_at, val
          when 'paid_at' then
            prepare_from_date search_with_attributes, :paid_at, val
          end
        end),
        :request_to_date => (lambda do |search_with_attributes, request_params, name, val|
          val = val.first if val && val.is_a?(Array)
          date_range_selector = request_params[:request_transaction][:date_range_selector] if request_params[:request_transaction]
          date_range_selector = request_params[:date_range_selector] unless date_range_selector
          case date_range_selector
          when 'due_at' then
            prepare_to_date search_with_attributes, :due_at, val
          when 'paid_at' then
            prepare_to_date search_with_attributes, :paid_at, val
          end
        end),
        :grant_program_ids => (lambda do |search_with_attributes, request_params, name, val|
          program_id_strings = val
          programs = Program.where(:id => program_id_strings).all.compact
          program_ids = programs.map do |program| 
            children = program.children_programs
            if children.empty?
              program
            else
              children
            end
          end.compact.flatten.map &:id
          search_with_attributes[:grant_program_ids] = program_ids if program_ids && !program_ids.empty?
        end),
        }
    end
    base.insta_realtime do |insta|
      insta.delta_attributes = SEARCH_ATTRIBUTES
      insta.updated_by_field = :updated_by_id
    end
    base.insta_multi
    base.insta_lock
    base.insta_utc do |insta|
      insta.time_attributes = [:due_at, :paid_at, :transaction_at] 
    end
    
    base.insta_role do |insta|
      # Define who is allowed to perform which events
      insta.add_event_roles 'mark_actually_due', Program, Program.grant_roles + Program.finance_roles
      insta.add_event_roles 'mark_paid', Program, Program.grant_roles + Program.finance_roles
      insta.add_admin_edit_for_roles Program.finance_administrator_role_name

      insta.extract_related_object do |model|
        model.request.program if model.request
      end
    end

    base.insta_workflow do |insta|
      insta.add_state_to_english :new, 'New', 'new'
      insta.add_state_to_english :tentatively_due, 'Tentatively Due', 'tentatively_due'
      insta.add_state_to_english :due, 'Actually Due', 'due'
      insta.add_state_to_english :paid, 'Paid', ['mark_paid', 'paid']
      
      insta.add_event_to_english :mark_actually_due, 'Mark Due'
      insta.add_event_to_english :mark_paid, 'Record Payment'

      insta.add_non_validating_event :reject
    end
    
    base.insta_template do |insta|
      insta.entity_name = 'request_transaction'
      insta.add_methods []
      insta.remove_methods [:id]
    end
    base.liquid_methods *( LIQUID_METHODS )

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    
    base.send :include, AASM
    base.add_aasm
    base.add_sphinx if base.respond_to?(:sphinx_indexes) && !(base.connection.adapter_name =~ /SQLite/i)
  end

  module ModelClassMethods
    # ESH: hack to rename User to Person
    def model_name
      rt = ActiveModel::Name.new RequestTransaction
      rt.instance_variable_set '@human', 'Transaction'
      rt
    end
    def add_sphinx
      # Allow the overriding of the state name
      state_name = if self.respond_to? :sphinx_state_name
        self.sphinx_state_name
      else
        'state'
      end
      
      define_index :request_transaction_first do
        # fields
        indexes request.program_organization.name, :as => :request_org_name, :sortable => true
        indexes request.program_organization.acronym, :as => :request_org_acronym, :sortable => true
        indexes "if(requests.type = 'FipRequest', concat('FG-',requests.base_request_id), concat('G-',requests.base_request_id))", :as => :request_grant_id, :sortable => true

        # attributes
        has created_at, updated_at, deleted_at, due_at, paid_at
        has "ROUND(request_transactions.amount_paid)", :as => :amount_paid, :type => :integer
        has "ROUND(request_transactions.amount_due)", :as => :amount_due, :type => :integer
        set_property :delta => :delayed
        has "request_transactions.#{state_name}", :type => :string, :crc => true, :as => :filter_state
        has "requests.#{state_name}", :type => :string, :crc => true, :as => :grant_state
        has grant(:id), :as => :grant_ids
        has grant.program(:id), :as => :grant_program_ids
        has grant.sub_program(:id), :as => :grant_sub_program_ids
        has request(:type), :type => :string, :crc => true, :as => :request_type
        has "IF((paid_at IS NOT NULL AND amount_paid IS NOT NULL), 1, 0)", :as => :has_been_paid, :type => :boolean
        has "CONCAT(IFNULL(`requests`.`program_organization_id`, '0'), ',', IFNULL(`requests`.`fiscal_organization_id`, '0'))", :as => :related_organization_ids, :type => :multi
        has grant.multi_element_choices.multi_element_value_id, :type => :multi, :as => :grant_multi_element_value_ids
        has grant.program_lead(:id), :as => :lead_user_ids
        has group_members.group(:id), :type => :multi, :as => :group_ids
        has favorites.user(:id), :as => :favorite_user_ids
        has request_transaction_funding_sources.request_funding_source.funding_source_allocation(:id), :as => :funding_source_allocation_id
        has FluxxGrantSphinxHelper.allocation_hierarchy, :type => :multi, :as => :allocation_hierarchy
        has FluxxGrantSphinxHelper.request_hierarchy, :type => :multi, :as => :request_hierarchy
      end
    end

    def mark_paid
      'mark_paid'
    end

    def add_aasm
      aasm_column :state
      aasm_initial_state :tentatively_due

      aasm_state :new
      aasm_state :paid
      aasm_state :tentatively_due
      aasm_state :due, :enter => :adjust_due_date

      aasm_event :mark_actually_due do
        transitions :from => [:new, :tentatively_due], :to => :due
      end
      	
      aasm_event :mark_paid do
      	transitions :from => [:new, :tentatively_due, :due], :to => :paid
      end
    end
    
    def document_title_name
      "Invoice"
    end
  end

  module ModelInstanceMethods
    def state_to_english
      RequestTransaction.state_to_english_translation state
    end

    def adjust_due_date
      self.due_at = Time.now
    end
    
    def has_been_paid
      state == 'paid' || (paid_at && amount_paid)
    end

    def title
      "Grant Transaction of #{amount_due.to_currency :precision => 0} for #{request.grant_id}" if amount_due && request
    end

    def filter_state
      self.state
    end

    def request_type
      request.type if request
    end

    def grant_program_ids
      if request && request.program
        [request.program.id]
      else
        []
      end
    end

    def grant_sub_program_ids
      if request && request.sub_program
        [request.sub_program.id]
      else
        []
      end
    end

    def amount_paid= new_amount
      write_attribute(:amount_paid, filter_amount(new_amount))
    end

    def amount_due= new_amount
      write_attribute(:amount_due, filter_amount(new_amount))
    end
    
    def related_users
      if request
        request.related_users
      end || []
    end
    
    def related_organizations
      if request
        request.related_organizations
      end || []
    end
    
    def related_grants
      [request]
    end
    
    def related_transactions
      if request
        request.related_request_transactions - [self]
      end || []
    end
    
    def validate_required_funding_source
      if request_transaction_funding_source_param_hash
        rtfs_list = request_transaction_funding_source_param_hash.keys.map do |rtfs|
          amount = request_transaction_funding_source_param_hash[rtfs]
        end.compact
        has_funding_source = !rtfs_list.empty?
        error = nil
        unless has_funding_source
          error = "You must specify an amount for at least one of the funding sources associated with the grant."
          errors[:Missing_Funding_source] << error
        end
        error
      end
    end
    
    def request_hierarchy
      request ? "#{request.program_id}-#{request.sub_program_id}-#{request.initiative_id}-#{request.sub_initiative_id}" : ''
    end
    
    def allocation_hierarchy
      if request
        request.request_funding_sources.map do |rfs|
          "#{rfs.program_id}-#{rfs.sub_program_id}-#{rfs.initiative_id}-#{rfs.sub_initiative_id}"
        end
      else
        ''
      end
    end
    
    def update_rtfs
      if request_transaction_funding_source_param_hash
        request_transaction_funding_source_param_hash.keys.each do |rtfs|
          amount = request_transaction_funding_source_param_hash[rtfs]
          if !amount.blank?
            if rtfs
              rtfs.request_transaction_id = self.id
              rtfs.amount = amount
              rtfs.updated_by_id = self.updated_by_id
              rtfs.save
            end
          elsif rtfs && rtfs.id && !rtfs.new_record?
            # The user removed the value, let's delete the record as well
            rtfs = rtfs.reload rescue nil # Note that for state transitions we essentially save twice; once to update the values and second time to do the state transition
            rtfs.destroy if rtfs
          end
        end
      end
    end
    
    def update_state_by_payment_type
      unless changed_attributes['state']
        paid_state = RequestTransaction.all_states_with_category('paid').first
      
        if payment_type == 'Credit Card' && state != paid_state
          update_attributes(:state => paid_state, :paid_at => Time.now, :amount_paid => amount_due) 
        end
      end
    end
    
    class Liquid::Drop
      def funding_source_names
        names=[] 
        for rtfs in @object.request_transaction_funding_sources do
          names << rtfs.request_funding_source.funding_source_allocation.funding_source.name
        end
        names
      end
    end

  end
end
