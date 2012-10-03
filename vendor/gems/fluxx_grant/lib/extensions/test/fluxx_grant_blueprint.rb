require 'machinist/active_record'
require 'sham'

require 'faker'

module FluxxGrantBlueprint

  def self.included(base)
    base.send :include, ::FluxxCrmBlueprint
  
    Program.blueprint do
      name random_words
    end

    SubProgram.blueprint do
      name random_word
      program_id 1
    end

    Initiative.blueprint do
      name random_words
      sub_program_id 1
    end

    SubInitiative.blueprint do
      name random_word
      initiative_id 1
    end

    FundingSource.blueprint do
      name random_words
    end

    GrantRequest.blueprint do
      project_summary do
        random_sentence
      end
      base_request_id nil
      amount_requested 45000
      amount_recommended 45001
      duration_in_months 12
      program
      program_organization
    end

    FipRequest.blueprint do
      fip_title random_sentence
      fip_type do
        bp_attrs[:fip_type_contract]
      end
      fip_projected_end_at (-10).days.ago.to_s(:db)
      project_summary do
        random_sentence
      end
      amount_requested 45000
      amount_recommended 45001
      duration_in_months 12
      program
    end

    Organization.blueprint do
      name random_words
      city random_words
      street_address random_words
      street_address2 random_words
      url Sham.url
      tax_class do
        bp_attrs[:non_er_tax_status]
      end
    end

    RequestReport.blueprint do
      request {GrantRequest.make}
      report_type RequestReport.interim_budget_type_name
    end

    RequestFundingSource.blueprint do
      funding_amount 5000
      funding_source_allocation {FundingSourceAllocation.make :amount => 50000}
      request {GrantRequest.make}
    end

    RequestEvaluationMetric.blueprint do
      request {GrantRequest.make}
      description random_words
      comment random_words
      achieved false
    end

    RequestTransaction.blueprint do
      request {GrantRequest.make}
    end

    RequestGeoState.blueprint do
    end

    RequestOrganization.blueprint do
      request {GrantRequest.make}
      organization {Organization.make}
    end

    RequestUser.blueprint do
      request {GrantRequest.make}
      user
    end

    ProjectRequest.blueprint do
      request {GrantRequest.make}
      project {Project.make}
    end

    FundingSourceAllocation.blueprint do
      funding_source {FundingSource.make}
      amount rand(99999)
      spending_year Time.now.year
    end
    
    FundingSourceAllocationAuthority.blueprint do
      authority_id {MultiElementValue.first.id}
    end
  
    RequestProgram.blueprint do
      request {GrantRequest.make}
      program {Program.make}
    end
    
    RequestTransactionFundingSource.blueprint do
    end

    BudgetRequest.blueprint do
      request {GrantRequest.make}
      name random_words
    end

    Loi.blueprint do
      organization {Organization.make}
      organization_name random_words
      email random_email
      applicant random_words
    end

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end
  
  module ModelInstanceMethods
    def setup_grant_multi_element_groups
      unless bp_attrs[:executed_setup_multi_element_groups]
        bp_attrs[:executed_setup_multi_element_groups] = true
        MultiElementValue.delete_all
        MultiElementGroup.delete_all
        project_type_group = MultiElementGroup.create :name => 'project_type', :description => 'ProjectType', :target_class_name => 'Project'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'Program'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'IT'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'Grants'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'Finance'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'HR'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'All Staff'
        ProjectList.add_multi_elements

        # project list types 
        project_list_type_group = MultiElementGroup.create :name => 'list_type', :description => 'ListType', :target_class_name => 'ProjectList'
        MultiElementValue.create :multi_element_group_id => project_list_type_group.id, :value => 'Numbers'
        MultiElementValue.create :multi_element_group_id => project_list_type_group.id, :value => 'Bulleted'
        MultiElementValue.create :multi_element_group_id => project_list_type_group.id, :value => 'To-Do'
        Project.add_multi_elements

        # FundingSourceAllocationAuthorities authority
        authority = MultiElementGroup.create :name => 'BoardAuthority', :description => 'authority', :target_class_name => 'FundingSourceAllocationAuthority'
        MultiElementValue.create :multi_element_group_id => authority.id, :value => '0909'
        FundingSourceAllocationAuthority.add_multi_elements
      end
    end
    
    def setup_grant_org_tax_classes
      unless bp_attrs[:executed_setup_org_tax_classes]
        MultiElementValue.delete_all
        bp_attrs[:executed_setup_org_tax_classes] = true
        MultiElementValue.make :multi_element_group_id => bp_attrs[:tax_class_group].id, :value => '509a1'
        bp_attrs[:non_er_tax_status] = MultiElementValue.make :multi_element_group_id => bp_attrs[:tax_class_group].id, :value => '509a2'
        MultiElementValue.make :multi_element_group_id => bp_attrs[:tax_class_group].id, :value => '509a3'
        MultiElementValue.make :multi_element_group_id => bp_attrs[:tax_class_group].id, :value => 'Private Foundation'
        MultiElementValue.make :multi_element_group_id => bp_attrs[:tax_class_group].id, :value => '501c4'
        MultiElementValue.make :multi_element_group_id => bp_attrs[:tax_class_group].id, :value => '501c6'
        MultiElementValue.make :multi_element_group_id => bp_attrs[:tax_class_group].id, :value => 'non-US'
        bp_attrs[:er_tax_status] = MultiElementValue.make :multi_element_group_id => bp_attrs[:tax_class_group].id, :value => 'Non-Exempt'
        Organization.add_multi_elements
      end
    end

    def setup_grant_fip_types
      bp_attrs[:fip_type_contract] = MultiElementValue.make :multi_element_group_id => bp_attrs[:fip_type_group].id, :value => 'Contract'
    end

    def setup_grant_multi_element_groups
      unless bp_attrs[:executed_setup_multi_element_groups]
        bp_attrs[:executed_setup_multi_element_groups] = true
        MultiElementValue.delete_all
        MultiElementGroup.delete_all
        bp_attrs[:test_program] = Program.make

        bp_attrs[:tax_class_group] = MultiElementGroup.make :name => 'tax_classes', :description => 'TaxClass', :target_class_name => 'Organization'
        MultiElementGroup.make :target_class_name => 'Request', :name => 'expenditure_types', :description => 'ExpenditureType'
        MultiElementGroup.make :target_class_name => 'Request', :name => 'initiative_types', :description => 'InitiativeType'
        MultiElementGroup.make :target_class_name => 'Request', :name => 'grant_types', :description => 'RequestGrantType'
        MultiElementGroup.make :target_class_name => 'Request', :name => 'constituents', :description => 'Constituents'
        MultiElementGroup.make :target_class_name => 'Request', :name => 'usa_means', :description => 'MeansUsa'
        MultiElementGroup.make :target_class_name => 'Request', :name => 'china_means', :description => 'MeansChina'
        MultiElementGroup.make :target_class_name => 'RequestFundingSource', :name => 'authorities', :description => 'BoardAuthority'
        MultiElementGroup.make :target_class_name => 'User', :name => 'user_salutations', :description => 'UserSalutation'
        bp_attrs[:fip_type_group] = MultiElementGroup.make :target_class_name => 'Request', :name => 'fip_types', :description => 'Fip Types'
        Request.add_multi_elements
        RequestFundingSource.add_multi_elements
        User.add_multi_elements

        project_type_group = MultiElementGroup.create :name => 'project_type', :description => 'ProjectType', :target_class_name => 'Project'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'Program'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'IT'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'Grants'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'Finance'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'HR'
        MultiElementValue.create :multi_element_group_id => project_type_group.id, :value => 'All Staff'
        ProjectList.add_multi_elements

        # project list types 
        project_list_type_group = MultiElementGroup.create :name => 'list_type', :description => 'ListType', :target_class_name => 'ProjectList'
        MultiElementValue.create :multi_element_group_id => project_list_type_group.id, :value => 'Numbers'
        MultiElementValue.create :multi_element_group_id => project_list_type_group.id, :value => 'Bulleted'
        MultiElementValue.create :multi_element_group_id => project_list_type_group.id, :value => 'To-Do'
        Project.add_multi_elements

        # Request funding source board authority
        board_authority_group = MultiElementGroup.create :name => 'board_authority', :description => 'Board Authorities', :target_class_name => 'RequestFundingSource'
        MultiElementValue.create :multi_element_group_id => board_authority_group.id, :value => '3/1/2010', :description => 'March 2010'
        MultiElementValue.create :multi_element_group_id => board_authority_group.id, :value => '6/1/2010', :description => 'June 2010'
        MultiElementValue.create :multi_element_group_id => board_authority_group.id, :value => '11/1/2010', :description => 'November 2010'
        MultiElementValue.create :multi_element_group_id => board_authority_group.id, :value => '1/1/2011', :description => 'January 2011'
        RequestFundingSource.add_multi_elements

      end
    end
  end
end
