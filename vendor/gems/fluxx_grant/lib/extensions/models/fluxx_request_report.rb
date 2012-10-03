module FluxxRequestReport
  SEARCH_ATTRIBUTES = [:grant_program_ids, :grant_sub_program_ids, :due_at, :approved_at, :report_type, :state, :updated_at, :grant_state, :favorite_user_ids, :request_hierarchy, :allocation_hierarchy] 
  LIQUID_METHODS = [:type_to_english, :due_at, :approved_at, :grant, :created_by, :updated_by]
  FAR_IN_THE_FUTURE = Time.now + 1000.year

  def self.included(base)
    base.belongs_to :request
    base.belongs_to :grant, :class_name => 'Request', :foreign_key => 'request_id', :conditions => {:granted => true}
    
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.has_many :workflow_events, :as => :workflowable
    base.has_many :favorites, :conditions => {:favorable_type => 'RequestReport'}, :foreign_key => :favorable_id # Override the favorites association to let it include all request types

    base.has_many :model_documents, :as => :documentable
    base.has_many :notes, :as => :notable, :conditions => {:deleted_at => nil}
    base.has_many :group_members, :as => :groupable
    base.has_many :groups, :through => :group_members

    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :modified_by_id, :locked_until, :locked_by_id, :delta, :updated_by, :created_by, :audits]})

    base.insta_search
    base.insta_export do |insta|
      insta.filename = 'report'
      insta.headers = [['Date Created', :date], ['Date Updated', :date], 'Request ID', 'state', 'Report Type', ['Date Due', :date], ['Date Approved', :date], 'Org Name', 
            ['Amount Recommended', :currency], 'Lead PO', 'Project Summary']
      insta.sql_query = "request_reports.created_at, request_reports.updated_at, requests.base_request_id request_id, request_reports.state, request_reports.report_type, request_reports.due_at, request_reports.approved_at, organizations.name program_org_name,
              requests.amount_recommended, 
              (select concat(users.first_name, (concat(' ', users.last_name))) full_name from
                users where id = program_lead_id) lead_po,
              requests.project_summary
              from request_reports
              left outer join requests on request_reports.request_id = requests.id
              left outer join organizations on requests.program_organization_id = organizations.id
              where request_reports.id IN (?)"
    end
    
    base.insta_favorite
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES + [:group_ids, :due_within_days, :overdue_by_days, :lead_user_ids, :request_hierarchy, :allocation_hierarchy]
      insta.derived_filters = {:due_within_days => (lambda do |search_with_attributes, request_params, name, value|
          value = value.first if value && value.is_a?(Array)
          if value.to_s.is_numeric?
            due_date_check = Time.now + value.to_i.days
            search_with_attributes[:due_at] = (Time.now.to_i..due_date_check.to_i)
            search_with_attributes[:has_been_approved] = false
          end || {}
        end),
        :overdue_by_days => (lambda do |search_with_attributes, request_params, name, value|
          value = value.first if value && value.is_a?(Array)
          if value.to_s.is_numeric?
            due_date_check = Time.now - value.to_i.days
            search_with_attributes[:due_at] = (0..due_date_check.to_i)
            search_with_attributes[:has_been_approved] = false
          end || {}
        end),
        :request_hierarchy => (lambda do |search_with_attributes, request_params, name, val|
          FluxxGrantSphinxHelper.prepare_hierarchy search_with_attributes, name, val
        end),
        :allocation_hierarchy => (lambda do |search_with_attributes, request_params, name, val|
          FluxxGrantSphinxHelper.prepare_hierarchy search_with_attributes, name, val
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
      insta.time_attributes = [:due_at, :approved_at, :bjo_received_at] 
    end
    
    base.insta_template do |insta|
      insta.entity_name = 'request_report'
      insta.add_methods [:type_to_english]
      insta.remove_methods [:id]
    end
    base.liquid_methods *( LIQUID_METHODS )

    base.send :include, AASM
    base.aasm_column :state
    base.aasm_initial_state :new

    base.aasm_state :new
    base.aasm_state :report_received
    base.aasm_state :pending_lead_approval
    base.aasm_state :pending_grant_team_approval
    base.aasm_state :pending_finance_approval
    base.aasm_state :approved, :enter => :adjust_request_transactions
    base.aasm_state :sent_back_to_pa
    base.aasm_state :sent_back_to_lead
    base.aasm_state :sent_back_to_grant_team

    base.aasm_event :receive_report do
      transitions :from => :new, :to => :report_received
    end

    base.aasm_event :submit_report do
      transitions :from => :report_received, :to => :pending_lead_approval
      transitions :from => :sent_back_to_pa, :to => :pending_lead_approval
    end

    base.aasm_event :lead_approve do
      transitions :from => [:pending_lead_approval, :sent_back_to_lead], :to => :pending_grant_team_approval
    end

    base.aasm_event :lead_send_back do
      transitions :from => [:pending_lead_approval, :sent_back_to_lead], :to => :sent_back_to_pa
    end

    base.aasm_event :grant_team_approve do
      transitions :from => [:sent_back_to_grant_team, :pending_grant_team_approval], :to => :pending_finance_approval, :guard => (lambda { |rep| rep.is_grant_er? && rep.is_final_budget_type? })
      transitions :from => [:sent_back_to_grant_team, :pending_grant_team_approval], :to => :approved, :guard => (lambda { |rep| !(rep.is_grant_er? && rep.is_final_budget_type?) })
    end

    base.aasm_event :grant_team_send_back do
      transitions :from => [:sent_back_to_grant_team, :pending_grant_team_approval], :to => :sent_back_to_lead
    end

    base.aasm_event :finance_approve do
      transitions :from => :pending_finance_approval, :to => :approved
    end

    base.aasm_event :finance_send_back do
      transitions :from => :pending_finance_approval, :to => :sent_back_to_grant_team
    end
    
    
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    
    # types:
    # RequestReport.final_eval_type_name => 'Eval',
    # RequestReport.final_budget_type_name => 'Final Financial',
    # RequestReport.final_narrative_type_name => 'Final Narrative',
    # RequestReport.interim_budget_type_name => 'Interim Financial',
    # RequestReport.interim_narrative_type_name => 'Interim Narrative',
    
    base.insta_role do |insta|
      # Define who is allowed to perform which events
      insta.add_event_roles RequestReport.receive_report_event, Program, Program.request_roles + Program.grantee_roles
      insta.add_event_roles RequestReport.submit_report_event, Program, Program.request_roles
      insta.add_event_roles RequestReport.lead_approve_event, Program, [Program.program_officer_role_name, Program.program_director_role_name]
      insta.add_event_roles RequestReport.lead_send_back_event, Program, [Program.program_director_role_name, Program.program_officer_role_name]
      insta.add_event_roles RequestReport.grant_team_approve_event, Program, Program.grant_roles
      insta.add_event_roles RequestReport.grant_team_send_back_event, Program, Program.grant_roles
      insta.add_event_roles RequestReport.finance_approve_event, Program, Program.finance_roles
      insta.add_event_roles RequestReport.finance_send_back_event, Program, Program.finance_roles

      insta.extract_related_object do |model|
        model.request.program if model.request
      end
    end

    base.insta_workflow do |insta|
      insta.add_state_to_english RequestReport.new_state, 'New', 'new'
      insta.add_state_to_english RequestReport.report_received_state, 'Report Received', 'approval'
      insta.add_state_to_english RequestReport.pending_lead_approval_state, 'Pending Lead Approval', 'approval'
      insta.add_state_to_english RequestReport.pending_grant_team_approval_state, 'Pending Grants Team Approval', 'approval'
      insta.add_state_to_english RequestReport.pending_finance_approval_state, 'Pending Finance Approval', 'approval'
      insta.add_state_to_english RequestReport.approved_state, 'Approved', 'approval'
      insta.add_state_to_english RequestReport.sent_back_to_pa_state, 'Sent Back to PA', 'sent_back'
      insta.add_state_to_english RequestReport.sent_back_to_lead_state, 'Sent Back to Lead', 'sent_back'
      insta.add_state_to_english RequestReport.sent_back_to_grant_team_state, 'Sent Back to Grants Team', 'sent_back'
      
      
      insta.add_event_to_english RequestReport.receive_report_event, 'Receive Report'
      insta.add_event_to_english RequestReport.submit_report_event, 'Submit Report'
      insta.add_event_to_english RequestReport.lead_approve_event, 'Approve'
      insta.add_event_to_english RequestReport.lead_send_back_event, 'Send Back'
      insta.add_event_to_english RequestReport.grant_team_approve_event, 'Approve'
      insta.add_event_to_english RequestReport.grant_team_send_back_event, 'Send Back'
      insta.add_event_to_english RequestReport.finance_approve_event, 'Approve'
      insta.add_event_to_english RequestReport.finance_send_back_event, 'Send Back'

      insta.add_non_validating_event :reject
      insta.add_non_validating_event RequestReport.lead_send_back_event
      insta.add_non_validating_event RequestReport.grant_team_send_back_event
      insta.add_non_validating_event RequestReport.finance_send_back_event
    end
    
    base.add_sphinx if base.respond_to?(:sphinx_indexes) && !(base.connection.adapter_name =~ /SQLite/i)
  end

  module ModelClassMethods
    def add_sphinx
      # Allow the overriding of the state name
      state_name = if self.respond_to? :sphinx_state_name
        self.sphinx_state_name
      else
        'state'
      end
      
      define_index :req_report_first do
        # fields
        indexes grant.program_organization.name, :as => :request_org_name, :sortable => true
        indexes grant.program_organization.acronym, :as => :request_org_acronym, :sortable => true
        indexes "if(requests.type = 'FipRequest', concat('FG-',requests.base_request_id), concat('G-',requests.base_request_id))", :as => :request_grant_id, :sortable => true

        # attributes
        has created_at, updated_at, deleted_at, due_at, approved_at
        set_property :delta => :delayed
        has grant(:id), :as => :grant_ids
        has grant.program(:id), :as => :grant_program_ids
        has grant.sub_program(:id), :as => :grant_sub_program_ids
        has "requests.#{state_name}", :type => :string, :crc => true, :as => :grant_state
        has :report_type, :type => :string, :crc => true
        has "request_reports.#{state_name}", :type => :string, :crc => true, :as => :state
        has 'null', :type => :multi, :as => :favorite_user_ids
        has "IF(request_reports.#{state_name} = 'approved', 1, 0)", :as => :has_been_approved, :type => :boolean
        has "CONCAT(IFNULL(`requests`.`program_organization_id`, '0'), ',', IFNULL(`requests`.`fiscal_organization_id`, '0'))", :as => :related_organization_ids, :type => :multi
        has grant.program_lead(:id), :as => :lead_user_ids
        
        has group_members.group(:id), :type => :multi, :as => :group_ids

        has FluxxGrantSphinxHelper.request_hierarchy, :type => :multi, :as => :request_hierarchy
        has 'null', :type => :multi, :as => :funding_source_ids
        has 'null', :type => :multi, :as => :allocation_hierarchy
      end

      define_index :req_report_second do
        # fields
        indexes grant.program_organization.name, :as => :request_org_name, :sortable => true
        indexes 'null', :type => :string, :as => :request_org_acronym, :sortable => true
        indexes 'null', :type => :string, :as => :request_grant_id, :sortable => true

        # attributes
        has created_at, updated_at, deleted_at, due_at, approved_at
        set_property :delta => :delayed
        has 'null', :type => :multi, :as => :grant_ids
        has 'null', :type => :multi, :as => :grant_program_ids
        has 'null', :type => :multi, :as => :grant_sub_program_ids
        has 'null', :type => :multi, :type => :string, :crc => true, :as => :grant_state
        has :report_type, :type => :string, :crc => true
        has "request_reports.#{state_name}", :type => :string, :crc => true, :as => :state
        has favorites.user(:id), :as => :favorite_user_ids
        has "IF(request_reports.#{state_name} = 'approved', 1, 0)", :as => :has_been_approved, :type => :boolean
        has 'null', :type => :multi, :as => :related_organization_ids
        has 'null', :type => :multi, :as => :lead_user_ids
        has 'null', :type => :multi, :as => :group_ids
        
        has FluxxGrantSphinxHelper.request_hierarchy, :type => :multi, :as => :request_hierarchy
        has grant.request_funding_sources.funding_source_allocation.funding_source(:id), :as => :funding_source_ids
        has FluxxGrantSphinxHelper.allocation_hierarchy, :type => :multi, :as => :allocation_hierarchy
      end
    end

    def final_monitor_type_name
      'FinalMonitor'
    end
    
    def final_eval_type_name
      'Eval'
    end

    def interim_eval_type_name
      'InterimEval'
    end

    def final_budget_type_name
      'FinalBudget'
    end

    def final_narrative_type_name
      'FinalNarrative'
    end

    def interim_budget_type_name
      'InterimBudget'
    end

    def interim_narrative_type_name
      'InterimNarrative'
    end

    def report_doc_types
      [interim_budget_type_name, interim_narrative_type_name, final_budget_type_name, final_narrative_type_name, final_eval_type_name, interim_eval_type_name, final_monitor_type_name]
    end
    
    def type_to_english_translation report_type
      case report_type
        when RequestReport.final_monitor_type_name then 'Monitor'
        when RequestReport.final_eval_type_name then 'Final Eval'
        when RequestReport.interim_eval_type_name then 'Interim Eval'
        when RequestReport.final_budget_type_name then 'Final Financial'
        when RequestReport.final_narrative_type_name then 'Final Narrative'
        when RequestReport.interim_budget_type_name then 'Interim Financial'
        when RequestReport.interim_narrative_type_name then 'Interim Narrative'
        else
          report_type.to_s
      end
    end
    
    
    def receive_report_event
      'receive_report'
    end
    def submit_report_event
      'submit_report'
    end
    def lead_approve_event
      'lead_approve'
    end
    def lead_send_back_event
      'lead_send_back'
    end
    def grant_team_approve_event
      'grant_team_approve'
    end
    def grant_team_send_back_event
      'grant_team_send_back'
    end
    def finance_approve_event
      'finance_approve'
    end
    def finance_send_back_event
      'finance_send_back'
    end

    def new_state
      'new'
    end
    def report_received_state
      'report_received'
    end
    def pending_lead_approval_state
      'pending_lead_approval'
    end
    def pending_grant_team_approval_state
      'pending_grant_team_approval'
    end
    def pending_finance_approval_state
      'pending_finance_approval'
    end
    def approved_state
      'approved'
    end
    def sent_back_to_pa_state
      'sent_back_to_pa'
    end
    def sent_back_to_lead_state
      'sent_back_to_lead'
    end
    def sent_back_to_grant_team_state
      'sent_back_to_grant_team'
    end

    def document_title_name
      'Report'
    end
  end

  module ModelInstanceMethods
    def title
      "#{type_to_english} #{request ? request.grant_id : ''}"
    end
    
    def is_final_monitor_report_type?
      report_type == RequestReport.final_monitor_type_name
    end

    def is_final_eval_report_type?
      report_type == RequestReport.final_eval_type_name
    end
    
    def is_interim_eval_report_type?
      report_type == RequestReport.interim_eval_type_name
    end
    
    def is_final_type?
      is_final_budget_type? || is_final_narrative_type?
    end

    def is_final_budget_type?
      report_type == RequestReport.final_budget_type_name
    end

    def is_final_narrative_type?
      report_type == RequestReport.final_narrative_type_name
    end

    def is_interim_type?
      is_interim_budget_type? || is_interim_narrative_type?
    end

    def is_interim_budget_type?
      report_type == RequestReport.interim_budget_type_name
    end


    def is_interim_narrative_type?
      report_type == RequestReport.interim_narrative_type_name
    end


    def type_to_english
      RequestReport.type_to_english_translation report_type
    end

    def grant_state
      grant.state if grant
    end

    def grant_program_ids
      if grant && grant.program
        [grant.program.id]
      else
        []
      end
    end

    def grant_sub_program_ids
      if grant && grant.sub_program
        [grant.sub_program.id]
      else
        []
      end
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
    
    def related_reports
      if request
        request.related_request_reports - [self]
      end || []
    end

    def is_approved?
      state == 'approved' && approved_at
    end

    def has_tax_class?
      grant && grant.has_tax_class?
    end

    def is_grant_er?
      grant && grant.is_er?
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
    
    def adjust_request_transactions
      self.approved_at = Time.now
      if self.report_type == 'InterimBudget' || self.report_type == 'InterimNarrative'
        request.request_transactions.each do |rt|
          if rt.in_state_with_category?('tentatively_due') && rt.request_document_linked_to == 'interim_request'
            rt.insta_fire_event :mark_actually_due, self.updated_by
            rt.save
          end
        end
      elsif self.report_type == 'FinalBudget' || self.report_type == 'FinalNarrative'
        request.request_transactions.each do |rt|
          if rt.in_state_with_category?('tentatively_due') && rt.request_document_linked_to == 'final_request'
            rt.insta_fire_event :mark_actually_due, self.updated_by
            rt.save
          end
        end
      end
    end

    def relates_to_user? user
      (user.primary_organization.id == self.request.program_organization_id) || (user.primary_organization.id == self.request.fiscal_organization_id)
    end
  end
end
