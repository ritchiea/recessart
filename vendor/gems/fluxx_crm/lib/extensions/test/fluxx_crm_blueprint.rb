require 'machinist/active_record'
require 'sham'

require 'faker'

module FluxxCrmBlueprint

  def self.included(base)
    base.send :include, ::FluxxEngineBlueprint

    Alert.blueprint do
      name random_words
      subject "the subject for {{recipient.email}}"
      body "the body for {{recipient.email}}"
      last_realtime_update_id -1
    end

    User.blueprint do
      first_name random_first_name
      last_name random_last_name
      login random_login
      email random_email
      created_at 5.days.ago.to_s(:db)
      state 'active'
      single_access_token Time.at(Time.now.to_i - rand(999999))
      persistence_token random_word
    end


    Organization.blueprint do
      name Sham.company_name
      city random_words
      street_address random_words
      street_address2 random_words
      url Sham.url
    end

    UserOrganization.blueprint do
      title random_words
      user_id User.make.id
      organization_id Organization.make.id
    end

    GeoCountry.blueprint do
      name do
        random_word
      end
      iso3 random_word
      fips104 random_word
    end

    GeoState.blueprint do
      name random_word
      abbreviation random_word
      fips_10_4 random_word
      geo_country_id GeoCountry.make.id
    end

    GeoCity.blueprint do
      name random_word
      geo_state_id GeoState.make.id
      geo_country_id GeoCountry.make.id
      original_id 1
    end

    ModelDocument.blueprint do
      documentable do
        User.make
      end
      document Sham.document
      document_file_name random_word
    end

    # this helper class creates classes so your blueprint is happy
    eval "class Documentable
      def self.make(attrs = {})
      end
    end"

    Document.blueprint do
      document Sham.document
    end

    Note.blueprint do
      note random_sentence
      notable_type 'User'
      notable_id User.make.id
    end

    Group.blueprint do
      name random_word
    end

    GroupMember.blueprint do
    end

    Favorite.blueprint do
      favorable_type 'User'
      favorable_id 1
    end

    Note.blueprint do
      note random_sentence
      notable_type 'User'
      notable_id User.make.id
    end

    Audit.blueprint do
      action 'create'
    end

    WorkflowEvent.blueprint do
      ip_address '127.0.0.1'
      old_state 'old_state'
      new_state 'new_state'
      comment 'comment'
    end

    RoleUser.blueprint do
    end

    UserProfile.blueprint do
      name 'board'
    end

    UserProfileRule.blueprint do
    end

    Project.blueprint do
      title random_sentence
      description random_sentence
    end

    ProjectList.blueprint do
      title random_sentence
      list_order 1
    end

    ProjectUser.blueprint do
    end

    ProjectOrganization.blueprint do
    end

    ProjectListItem.blueprint do
      name random_word
      list_item_text random_sentence
      due_at Time.now
      item_order 1
    end

    WikiDocument.blueprint do
      model_type Organization.name
      wiki_order 1
      title random_word
      note random_sentence
    end

    WikiDocumentTemplate.blueprint do
      model_type Organization.name
      document_type random_word
      filename random_word
      description random_word
      category random_word
      document random_sentence
    end

    ModelDocumentTemplate.blueprint do
      model_type Organization.name
      document_type random_word
      filename random_word
      description random_word
      category random_word
      document random_sentence
    end
    
    ModelDocumentType.blueprint do
    end
    
    BankAccount.blueprint do
      bank_name random_words
      account_name random_word
      account_number random_word
      special_instructions random_sentence
      street_address random_words
      street_address2 random_words
      city random_words
      postal_code random_word
      phone  random_word
      fax random_word
      bank_code random_word
      bank_contact_name "#{random_first_name} #{random_last_name}"
      bank_contact_phone random_word
      domestic_wire_aba_routing random_words
      domestic_special_wire_instructions random_words
      foreign_wire_intermediary_bank_name random_words
      foreign_wire_intermediary_bank_swift random_sentence
      foreign_wire_beneficiary_bank_swift random_sentence
      foreign_special_wire_instructions random_sentence
    end
    
    WorkTask.blueprint do
      name random_word
      task_text random_sentence
      due_at Time.now
      task_order 1
    end
    Role.blueprint do
      name random_word
    end
    UserPermission.blueprint do
    end

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end
  
  module ModelInstanceMethods
    def setup_crm_multi_element_groups
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
      end
    end
  end
end
