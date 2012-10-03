module FluxxFipRequest
  def self.included(base)
    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :modified_by_id, :locked_until, :locked_by_id, :delta, :updated_by, :created_by, :audits]})

    base.validates_presence_of     :fip_title
    base.validates_presence_of     :fip_type
    base.validates_presence_of     :fip_projected_end_at
    base.validates_presence_of     :program
    base.validates_presence_of     :project_summary
    base.validates_presence_of     :amount_requested
    base.validates_associated      :program
    base.has_many :workflow_events, :foreign_key => :workflowable_id, :conditions => {:workflowable_type => base.name}
    base.has_many :favorites, :foreign_key => :favorable_id, :conditions => {:favorable_type => base.name}
    base.has_many :notes, :foreign_key => :notable_id, :conditions => {:notable_type => base.name}
    base.has_many :group_members, :foreign_key => :groupable_id, :conditions => {:groupable_type => base.name}
    base.has_many :model_documents, :foreign_key => :documentable_id, :conditions => {:documentable_type => base.name}
    base.has_many :wiki_documents, :foreign_key => :model_id, :conditions => {:model_type => base.name}
    base.has_many :request_amendments, :as => :request
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    
    base.add_grant_request_install_role
  end

  module ModelClassMethods
    def model_name
      u = ActiveModel::Name.new FipRequest
      u.instance_variable_set '@human', "#{I18n.t(:fip_name)} Request"
      u
    end
    
    def add_grant_request_install_role 
      insta_role do |insta|
        # Define who is allowd to perform which events
        insta.add_event_roles 'submit_draft', Program, Program.grantee_roles
        insta.add_event_roles 'reject', Program, Program.request_roles
        insta.add_event_roles 'un_reject', Program, Program.request_roles
        insta.add_event_roles 'recommend_funding', Program, Program.request_roles
        insta.add_event_roles 'complete_ierf', Program, Program.request_roles
        insta.add_event_roles 'grant_team_approve', Program, Program.grant_roles
        insta.add_event_roles 'grant_team_send_back', Program, Program.grant_roles
        insta.add_event_roles 'po_approve', Program, Program.program_officer_role_name
        insta.add_event_roles 'po_send_back', Program, Program.program_officer_role_name
        insta.add_event_roles 'pd_approve', Program, Program.program_director_role_name
        insta.add_event_roles 'secondary_pd_approve', Program, Program.program_director_role_name
        insta.add_event_roles 'pd_send_back', Program, Program.program_director_role_name
        insta.add_event_roles 'cr_approve', Program, Program.cr_role_name
        insta.add_event_roles 'cr_send_back', Program, Program.cr_role_name
        insta.add_event_roles 'deputy_director_approve', Program, Program.deputy_director_role_name
        insta.add_event_roles 'deputy_director_send_back', Program, Program.deputy_director_role_name
        insta.add_event_roles 'svp_approve', Program, Program.svp_role_name
        insta.add_event_roles 'svp_send_back', Program, Program.svp_role_name
        insta.add_event_roles 'president_approve', Program, Program.president_role_name
        insta.add_event_roles 'president_send_back', Program, Program.president_role_name
        insta.add_event_roles 'become_grant', Program, Program.finance_roles
        insta.add_event_roles 'close_grant', Program, Program.grant_roles
        insta.add_event_roles 'fip_close_grant', Program, Program.finance_roles
        insta.add_event_roles 'cancel_grant', Program, Program.finance_roles

        insta.extract_related_object do |model|
          result = if model.in_state_with_category? 'pending_secondary_pd_approval'
              model.request_programs.reject{|rp| rp.is_approved?}.map{|rp| rp.program}.compact
          else
            model.program
          end
          result
        end
      end
    end
  end

  module ModelInstanceMethods
    attr_accessor :amend
    attr_accessor :amend_note
    alias_method :amend?, :amend

    def request_prefix
      'FR'
    end

    def grant_prefix
      'FG'
    end

    def generate_grant_details
      generate_grant_dates
    end

    def append_amendment_note
      note = []
      note << "Amount amended from #{amount_recommended_was} to #{amount_recommended}." if amount_recommended_changed?
      note << "Duration amended from #{duration_in_months_was} to #{duration_in_months}." if duration_in_months_changed?
      note << amend_note unless amend_note.to_s.empty?
      notes.build(:note => note.join(" "))
    end

  end
end
