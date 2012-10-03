# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120321211608) do

  create_table "alert_emails", :force => true do |t|
    t.string   "mailer_method"
    t.integer  "attempts",        :default => 0
    t.datetime "last_attempt_at"
    t.boolean  "delivered",       :default => false
    t.integer  "alert_id"
    t.integer  "model_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model_type"
    t.datetime "send_at"
    t.text     "email_params"
  end

  create_table "alert_recipients", :force => true do |t|
    t.integer  "user_id"
    t.integer  "alert_id"
    t.text     "rtu_model_user_method"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alert_transition_states", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "alert_id"
    t.string   "state"
  end

  add_index "alert_transition_states", ["alert_id"], :name => "alert_transition_states_alert_id"
  add_index "alert_transition_states", ["created_by_id"], :name => "alert_transition_states_created_by_id"
  add_index "alert_transition_states", ["updated_by_id"], :name => "alert_transition_states_updated_by_id"

  create_table "alerts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_realtime_update_id"
    t.string   "model_controller_type"
    t.text     "filter"
    t.string   "subject"
    t.text     "body"
    t.string   "name"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
    t.integer  "dashboard_id"
    t.integer  "dashboard_card_id"
    t.boolean  "group_models",            :default => false, :null => false
    t.boolean  "state_driven",            :default => false, :null => false
    t.text     "cc_emails"
    t.text     "bcc_emails"
    t.boolean  "alert_enabled",           :default => true,  :null => false
  end

  add_index "alerts", ["dashboard_id"], :name => "alerts_dashboard_id"

  create_table "audits", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audit_changes"
    t.integer  "version",        :default => 0
    t.string   "comment"
    t.text     "full_model"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "bank_accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "bank_name"
    t.string   "account_name"
    t.string   "account_number"
    t.string   "special_instructions"
    t.string   "street_address"
    t.string   "street_address2"
    t.string   "city"
    t.integer  "geo_state_id"
    t.integer  "geo_country_id"
    t.string   "postal_code",                          :limit => 100
    t.string   "phone",                                :limit => 100
    t.string   "fax",                                  :limit => 100
    t.string   "bank_code"
    t.string   "bank_contact_name"
    t.string   "bank_contact_phone"
    t.string   "domestic_wire_aba_routing"
    t.string   "domestic_special_wire_instructions"
    t.string   "foreign_wire_intermediary_bank_name"
    t.string   "foreign_wire_intermediary_bank_swift"
    t.string   "foreign_wire_beneficiary_bank_swift"
    t.string   "foreign_special_wire_instructions"
    t.integer  "owner_organization_id"
    t.integer  "owner_user_id"
  end

  add_index "bank_accounts", ["created_by_id"], :name => "bank_accounts_created_by_id"
  add_index "bank_accounts", ["geo_country_id"], :name => "bank_accounts_geo_country_id"
  add_index "bank_accounts", ["geo_state_id"], :name => "bank_accounts_geo_state_id"
  add_index "bank_accounts", ["owner_organization_id"], :name => "bank_accounts_owner_organization_id"
  add_index "bank_accounts", ["owner_user_id"], :name => "bank_accounts_owner_user_id"
  add_index "bank_accounts", ["updated_by_id"], :name => "bank_accounts_updated_by_id"

  create_table "budget_requests", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id",                                        :null => false
    t.decimal  "amount_requested",   :precision => 15, :scale => 2
    t.decimal  "amount_recommended", :precision => 15, :scale => 2
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
  end

  add_index "budget_requests", ["created_by_id"], :name => "budget_requests_created_by_id"
  add_index "budget_requests", ["request_id"], :name => "index_budget_requests_on_request_id"
  add_index "budget_requests", ["updated_by_id"], :name => "budget_requests_updated_by_id"

  create_table "client_stores", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "client_store_type"
    t.string   "name"
    t.datetime "deleted_at"
    t.text     "data",              :limit => 2147483647
  end

  add_index "client_stores", ["user_id", "client_store_type"], :name => "index_client_stores_on_user_id_and_client_store_type"
  add_index "client_stores", ["user_id"], :name => "index_client_stores_on_user_id"

  create_table "dashboard_templates", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name"
    t.text     "data"
  end

  add_index "dashboard_templates", ["created_by_id"], :name => "dashboard_templates_created_by_id"
  add_index "dashboard_templates", ["updated_by_id"], :name => "dashboard_templates_updated_by_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "documents", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
  end

  add_index "documents", ["created_by_id"], :name => "documents_created_by_id"
  add_index "documents", ["updated_by_id"], :name => "documents_updated_by_id"

  create_table "favorites", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "favorable_type", :null => false
    t.integer  "favorable_id",   :null => false
  end

  add_index "favorites", ["favorable_type", "favorable_id"], :name => "index_favorites_on_favorable_type_and_favorable_id"
  add_index "favorites", ["user_id"], :name => "favorites_user_id"

  create_table "funding_source_allocation_authorities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.decimal  "amount",                       :precision => 15, :scale => 2
    t.integer  "authority_id"
    t.integer  "funding_source_allocation_id"
    t.text     "note"
  end

  add_index "funding_source_allocation_authorities", ["authority_id"], :name => "fsa_authorities_authority_id"
  add_index "funding_source_allocation_authorities", ["created_by_id"], :name => "fsa_authorities_created_by_id"
  add_index "funding_source_allocation_authorities", ["funding_source_allocation_id"], :name => "fsa_authorities_fsa_id"
  add_index "funding_source_allocation_authorities", ["updated_by_id"], :name => "fsa_authorities_updated_by_id"

  create_table "funding_source_allocations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "funding_source_id"
    t.integer  "program_id"
    t.integer  "sub_program_id"
    t.integer  "initiative_id"
    t.integer  "sub_initiative_id"
    t.decimal  "amount",               :precision => 15, :scale => 2
    t.boolean  "retired"
    t.integer  "locked_by_id"
    t.datetime "locked_until"
    t.datetime "deleted_at"
    t.integer  "spending_year"
    t.decimal  "budget_amount",        :precision => 15, :scale => 2
    t.decimal  "actual_budget_amount", :precision => 15, :scale => 2
  end

  add_index "funding_source_allocations", ["created_by_id"], :name => "funding_source_allocations_created_by_id"
  add_index "funding_source_allocations", ["funding_source_id"], :name => "funding_source_allocations_funding_source_id"
  add_index "funding_source_allocations", ["initiative_id"], :name => "funding_source_allocations_initiative_id"
  add_index "funding_source_allocations", ["program_id"], :name => "funding_source_allocations_program_id"
  add_index "funding_source_allocations", ["sub_initiative_id"], :name => "funding_source_allocations_sub_initiative_id"
  add_index "funding_source_allocations", ["sub_program_id"], :name => "funding_source_allocations_sub_program_id"
  add_index "funding_source_allocations", ["updated_by_id"], :name => "funding_source_allocations_updated_by_id"

  create_table "funding_sources", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name"
    t.decimal  "amount",                        :precision => 15, :scale => 2
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "retired",                                                      :default => false,      :null => false
    t.decimal  "overhead_amount",               :precision => 15, :scale => 2
    t.decimal  "net_available_to_spend_amount", :precision => 15, :scale => 2
    t.integer  "narrative_lead_user_id"
    t.string   "state",                                                        :default => "approved", :null => false
    t.decimal  "amount_requested",              :precision => 15, :scale => 2
    t.decimal  "amount_budgeted",               :precision => 15, :scale => 2
  end

  create_table "geo_cities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",           :limit => 150, :null => false
    t.integer  "geo_state_id"
    t.integer  "geo_country_id"
    t.string   "postalCode",     :limit => 150
    t.string   "latitude",       :limit => 150
    t.string   "longitude",      :limit => 150
    t.string   "metro_code",     :limit => 150
    t.string   "area_code",      :limit => 150
    t.integer  "original_id",                   :null => false
  end

  add_index "geo_cities", ["geo_country_id"], :name => "geo_cities_country_id"
  add_index "geo_cities", ["geo_state_id"], :name => "geo_cities_state_id"
  add_index "geo_cities", ["name"], :name => "geo_cities_name_index"

  create_table "geo_countries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                 :limit => 90, :null => false
    t.string   "fips104",              :limit => 90
    t.string   "iso2",                 :limit => 90
    t.string   "iso3",                 :limit => 90
    t.string   "ison",                 :limit => 90
    t.string   "internet",             :limit => 90
    t.string   "capital",              :limit => 90
    t.string   "map_reference",        :limit => 90
    t.string   "nationality_singular", :limit => 90
    t.string   "nationality_plural",   :limit => 90
    t.string   "currency",             :limit => 90
    t.string   "currency_code",        :limit => 90
    t.string   "population",           :limit => 90
    t.string   "title",                :limit => 90
    t.text     "comment"
  end

  add_index "geo_countries", ["iso2"], :name => "country_iso2_index"
  add_index "geo_countries", ["name"], :name => "country_name_index"

  create_table "geo_regions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       :null => false
  end

  create_table "geo_states", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",           :limit => 90, :null => false
    t.string   "fips_10_4",      :limit => 90, :null => false
    t.string   "abbreviation",   :limit => 25
    t.integer  "geo_country_id",               :null => false
    t.integer  "geo_region_id"
  end

  add_index "geo_states", ["abbreviation"], :name => "geo_states_abbrv_index"
  add_index "geo_states", ["geo_country_id"], :name => "geo_states_country_id"
  add_index "geo_states", ["geo_region_id"], :name => "geo_states_geo_region_id"
  add_index "geo_states", ["name"], :name => "geo_states_name_index"

  create_table "group_members", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "group_id"
    t.integer  "groupable_id"
    t.string   "groupable_type"
  end

  add_index "group_members", ["group_id"], :name => "index_group_members_on_group_id"
  add_index "group_members", ["groupable_id", "groupable_type"], :name => "index_group_members_on_groupable_id_and_groupable_type"

  create_table "groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name"
    t.boolean  "deprecated",    :default => false
  end

  add_index "groups", ["name"], :name => "index_groups_on_name", :unique => true

  create_table "initiatives", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name",                              :null => false
    t.text     "description"
    t.integer  "sub_program_id",                    :null => false
    t.boolean  "retired",        :default => false, :null => false
    t.integer  "migrate_id"
  end

  add_index "initiatives", ["created_by_id"], :name => "sub_programs_created_by_id"
  add_index "initiatives", ["sub_program_id"], :name => "index_sub_programs_on_initiative_id"
  add_index "initiatives", ["updated_by_id"], :name => "sub_programs_updated_by_id"

  create_table "lois", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "applicant"
    t.string   "organization_name"
    t.string   "project_title"
    t.string   "email"
    t.string   "phone"
    t.text     "project_summary"
    t.string   "address"
    t.integer  "program_id"
    t.integer  "locked_by_id"
    t.datetime "locked_until"
    t.datetime "deleted_at"
    t.integer  "user_id"
    t.integer  "request_id"
    t.integer  "organization_id"
    t.boolean  "delta",                                                                             :default => true
    t.string   "tax_id"
    t.decimal  "amount_requested",                                   :precision => 15, :scale => 2
    t.integer  "sub_program_id"
    t.integer  "duration_in_months"
    t.datetime "grant_begins_at"
    t.string   "street_address2"
    t.string   "city",                               :limit => 100
    t.integer  "geo_state_id"
    t.integer  "geo_country_id"
    t.string   "postal_code",                        :limit => 100
    t.integer  "migrate_id"
    t.string   "organization_name_foreign_language", :limit => 1500
    t.string   "state"
  end

  add_index "lois", ["created_by_id"], :name => "lois_created_by_id"
  add_index "lois", ["updated_by_id"], :name => "lois_updated_by_id"

  create_table "model_document_templates", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "model_type"
    t.string   "document_type"
    t.string   "filename"
    t.string   "description"
    t.string   "category"
    t.text     "document"
    t.datetime "deleted_at"
    t.boolean  "delta",                              :default => true,  :null => false
    t.boolean  "display_in_adhoc_list",              :default => false, :null => false
    t.string   "generate_state"
    t.string   "document_content_type"
    t.string   "disposition"
    t.integer  "related_model_document_template_id"
    t.boolean  "do_not_insert_page_break"
  end

  add_index "model_document_templates", ["category"], :name => "index_model_document_templates_on_category"
  add_index "model_document_templates", ["created_by_id"], :name => "modeldoctemplate_created_by_id"
  add_index "model_document_templates", ["document_type"], :name => "index_model_document_templates_on_document_type"
  add_index "model_document_templates", ["model_type"], :name => "index_model_document_templates_on_model_type"
  add_index "model_document_templates", ["related_model_document_template_id"], :name => "mdt_related_model_doc_templt_id"
  add_index "model_document_templates", ["updated_by_id"], :name => "modeldoctemplate_updated_by_id"

  create_table "model_document_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name",                                     :null => false
    t.string   "model_type",                               :null => false
    t.boolean  "required",          :default => true,      :null => false
    t.integer  "program_id"
    t.integer  "sub_program_id"
    t.integer  "initiative_id"
    t.integer  "sub_initiative_id"
    t.string   "doc_label",         :default => "default", :null => false
  end

  add_index "model_document_types", ["created_by_id"], :name => "model_document_types_created_by_id"
  add_index "model_document_types", ["doc_label"], :name => "index_model_document_types_on_doc_label"
  add_index "model_document_types", ["initiative_id"], :name => "model_document_types_initiative_id"
  add_index "model_document_types", ["model_type", "doc_label"], :name => "mod_docs_type_docid_label"
  add_index "model_document_types", ["model_type"], :name => "index_model_document_types_on_model_type"
  add_index "model_document_types", ["program_id"], :name => "model_document_types_program_id"
  add_index "model_document_types", ["sub_initiative_id"], :name => "model_document_types_sub_initiative_id"
  add_index "model_document_types", ["sub_program_id"], :name => "model_document_types_sub_program_id"
  add_index "model_document_types", ["updated_by_id"], :name => "model_document_types_updated_by_id"

  create_table "model_documents", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.string   "documentable_type",                                 :null => false
    t.integer  "documentable_id",                                   :null => false
    t.datetime "locked_until"
    t.integer  "locked_by_id"
    t.integer  "model_document_type_id"
    t.string   "document_type",              :default => "file"
    t.text     "document_text"
    t.integer  "model_document_template_id"
    t.string   "doc_label",                  :default => "default", :null => false
    t.string   "s3_permission"
  end

  add_index "model_documents", ["doc_label"], :name => "index_model_documents_on_doc_label"
  add_index "model_documents", ["documentable_id", "documentable_type"], :name => "model_documents_docid_type"
  add_index "model_documents", ["documentable_type", "documentable_id", "doc_label"], :name => "mod_docs_type_docid_label"
  add_index "model_documents", ["documentable_type", "documentable_id"], :name => "model_documents_doc_type_id"
  add_index "model_documents", ["model_document_template_id"], :name => "model_documents_template_id"
  add_index "model_documents", ["model_document_type_id"], :name => "model_documents_model_document_type_id"

  create_table "multi_element_choices", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "target_id",              :null => false
    t.integer  "multi_element_value_id", :null => false
  end

  add_index "multi_element_choices", ["multi_element_value_id"], :name => "multi_element_choice_value_id"
  add_index "multi_element_choices", ["target_id", "multi_element_value_id"], :name => "multi_element_choices_index_cl_attr_val", :unique => true

  create_table "multi_element_groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "target_class_name", :null => false
    t.string   "name"
    t.string   "description"
  end

  create_table "multi_element_values", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.string   "value"
    t.integer  "multi_element_group_id"
    t.integer  "dependent_multi_element_value_id"
  end

  add_index "multi_element_values", ["dependent_multi_element_value_id"], :name => "multi_element_values_dependent_value_id"
  add_index "multi_element_values", ["multi_element_group_id"], :name => "index_multi_element_values_on_multi_element_group_id"

  create_table "notes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.text     "note",                            :null => false
    t.string   "notable_type",                    :null => false
    t.integer  "notable_id",                      :null => false
    t.boolean  "delta",         :default => true
    t.datetime "deleted_at"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
  end

  add_index "notes", ["created_by_id"], :name => "notes_created_by_id"
  add_index "notes", ["notable_type", "notable_id"], :name => "index_notes_on_notable_type_and_notable_id"
  add_index "notes", ["updated_by_id"], :name => "notes_updated_by_id"

  create_table "organizations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name",                   :limit => 1000,                    :null => false
    t.string   "street_address"
    t.string   "street_address2"
    t.string   "city",                   :limit => 100
    t.integer  "geo_state_id"
    t.integer  "geo_country_id"
    t.string   "postal_code",            :limit => 100
    t.string   "phone",                  :limit => 100
    t.string   "other_contact",          :limit => 100
    t.string   "fax",                    :limit => 100
    t.string   "email",                  :limit => 100
    t.string   "url",                    :limit => 2048
    t.string   "blog_url",               :limit => 2048
    t.string   "twitter_url",            :limit => 2048
    t.string   "acronym",                :limit => 100
    t.string   "state",                                  :default => "new"
    t.boolean  "delta",                                  :default => true
    t.datetime "deleted_at"
    t.integer  "parent_org_id"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
    t.integer  "tax_class_id"
    t.string   "tax_id"
    t.boolean  "c3_status_approved",                     :default => false, :null => false
    t.text     "c3_serialized_response"
    t.string   "vendor_number"
    t.boolean  "is_grantor",                             :default => false
    t.integer  "migrate_id"
    t.string   "name_foreign_language",  :limit => 1500
    t.float    "latitude"
    t.float    "longitude"
    t.string   "state_str"
    t.string   "state_code"
    t.string   "country_str"
    t.string   "country_code"
  end

  add_index "organizations", ["created_by_id"], :name => "organizations_created_by_id"
  add_index "organizations", ["geo_country_id"], :name => "organizations_geo_country_id"
  add_index "organizations", ["geo_state_id"], :name => "organizations_geo_state_id"
  add_index "organizations", ["name"], :name => "index_organizations_on_name", :length => {"name"=>255}
  add_index "organizations", ["parent_org_id", "deleted_at"], :name => "index_organizations_on_parent_org_id_and_deleted_at"
  add_index "organizations", ["parent_org_id"], :name => "index_organizations_on_parent_org_id"
  add_index "organizations", ["updated_by_id"], :name => "organizations_updated_by_id"

  create_table "program_budgets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "program_id"
    t.integer  "sub_program_id"
    t.integer  "initiative_id"
    t.integer  "sub_initiative_id"
    t.integer  "spending_year"
    t.decimal  "amount",            :precision => 15, :scale => 2
    t.integer  "locked_by_id"
    t.datetime "locked_until"
    t.datetime "deleted_at"
  end

  add_index "program_budgets", ["created_by_id"], :name => "program_budgets_created_by_id"
  add_index "program_budgets", ["initiative_id"], :name => "program_budgets_initiative_id"
  add_index "program_budgets", ["program_id"], :name => "program_budgets_program_id"
  add_index "program_budgets", ["spending_year", "initiative_id"], :name => "index_program_budgets_on_spending_year_and_initiative_id"
  add_index "program_budgets", ["spending_year", "program_id"], :name => "index_program_budgets_on_spending_year_and_program_id"
  add_index "program_budgets", ["spending_year", "sub_initiative_id"], :name => "index_program_budgets_on_spending_year_and_sub_initiative_id"
  add_index "program_budgets", ["spending_year", "sub_program_id"], :name => "index_program_budgets_on_spending_year_and_sub_program_id"
  add_index "program_budgets", ["sub_initiative_id"], :name => "program_budgets_subinitiative_id"
  add_index "program_budgets", ["sub_program_id"], :name => "program_budgets_sub_program_id"
  add_index "program_budgets", ["updated_by_id"], :name => "program_budgets_updated_by_id"

  create_table "programs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name"
    t.string   "description"
    t.integer  "parent_id"
    t.boolean  "rollup"
    t.integer  "geo_zone_id"
    t.boolean  "retired",       :default => false, :null => false
    t.integer  "migrate_id"
  end

  add_index "programs", ["geo_zone_id"], :name => "program_geo_zone_id"
  add_index "programs", ["parent_id"], :name => "index_programs_on_parent_id"

  create_table "project_list_items", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name"
    t.text     "list_item_text"
    t.integer  "project_list_id"
    t.datetime "due_at"
    t.integer  "item_order"
    t.integer  "assigned_user_id"
    t.boolean  "item_completed",   :default => false
    t.datetime "deleted_at"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
  end

  add_index "project_list_items", ["assigned_user_id"], :name => "project_list_items_assigned_user_id"
  add_index "project_list_items", ["created_by_id"], :name => "project_list_items_created_by_id"
  add_index "project_list_items", ["project_list_id"], :name => "project_list_items_project_list_id"
  add_index "project_list_items", ["updated_by_id"], :name => "project_list_items_updated_by_id"

  create_table "project_lists", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "title"
    t.integer  "project_id"
    t.integer  "list_order"
    t.integer  "list_type_id"
    t.datetime "deleted_at"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
  end

  add_index "project_lists", ["created_by_id"], :name => "project_lists_created_by_id"
  add_index "project_lists", ["project_id"], :name => "project_lists_project_id"
  add_index "project_lists", ["updated_by_id"], :name => "project_lists_updated_by_id"

  create_table "project_organizations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "project_id"
    t.integer  "organization_id"
    t.string   "description"
  end

  add_index "project_organizations", ["created_by_id"], :name => "project_organizations_created_by_id"
  add_index "project_organizations", ["organization_id"], :name => "project_organizations_organization_id"
  add_index "project_organizations", ["project_id"], :name => "project_organizations_project_id"
  add_index "project_organizations", ["updated_by_id"], :name => "project_organizations_updated_by_id"

  create_table "project_requests", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "project_id"
    t.integer  "request_id"
    t.boolean  "granted"
    t.string   "description"
  end

  add_index "project_requests", ["created_by_id"], :name => "project_requests_created_by_id"
  add_index "project_requests", ["project_id"], :name => "project_requests_project_id"
  add_index "project_requests", ["request_id"], :name => "project_requests_request_id"
  add_index "project_requests", ["updated_by_id"], :name => "project_requests_updated_by_id"

  create_table "project_users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "description"
  end

  add_index "project_users", ["created_by_id"], :name => "project_users_created_by_id"
  add_index "project_users", ["project_id"], :name => "project_users_project_id"
  add_index "project_users", ["updated_by_id"], :name => "project_users_updated_by_id"
  add_index "project_users", ["user_id"], :name => "project_users_user_id"

  create_table "projects", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "title"
    t.text     "description"
    t.string   "state"
    t.integer  "project_type_id"
    t.integer  "lead_user_id"
    t.datetime "deleted_at"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
    t.boolean  "delta",           :default => true, :null => false
  end

  add_index "projects", ["created_by_id"], :name => "projects_created_by_id"
  add_index "projects", ["lead_user_id"], :name => "projects_lead_user_id"
  add_index "projects", ["updated_by_id"], :name => "projects_updated_by_id"

  create_table "realtime_updates", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action",           :null => false
    t.integer  "user_id"
    t.integer  "model_id",         :null => false
    t.string   "type_name",        :null => false
    t.string   "model_class",      :null => false
    t.text     "delta_attributes", :null => false
  end

  create_table "request_amendments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration"
    t.datetime "start_date"
    t.datetime "end_date"
    t.decimal  "amount_recommended",     :precision => 15, :scale => 2
    t.boolean  "original",                                              :default => false
    t.integer  "request_id"
    t.string   "request_type"
    t.string   "state"
    t.text     "note"
    t.boolean  "delta",                                                 :default => true,  :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "old_duration"
    t.datetime "old_start_date"
    t.datetime "old_end_date"
    t.decimal  "old_amount_recommended", :precision => 15, :scale => 2
  end

  create_table "request_evaluation_metrics", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id",    :null => false
    t.text     "description"
    t.text     "comment"
    t.boolean  "achieved"
    t.string   "timeframe"
  end

  add_index "request_evaluation_metrics", ["request_id"], :name => "request_evaluation_metrics_request_id"

  create_table "request_funding_sources", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id"
    t.string   "document_file_name"
    t.decimal  "funding_amount",               :precision => 15, :scale => 2
    t.integer  "locked_by_id"
    t.datetime "locked_until"
    t.integer  "funding_source_allocation_id"
    t.integer  "program_id"
    t.integer  "sub_program_id"
    t.integer  "initiative_id"
    t.integer  "sub_initiative_id"
  end

  add_index "request_funding_sources", ["funding_source_allocation_id"], :name => "rfs_funding_source_allocation_id"
  add_index "request_funding_sources", ["initiative_id"], :name => "request_funding_sources_initiative_id"
  add_index "request_funding_sources", ["program_id"], :name => "request_funding_sources_program_id"
  add_index "request_funding_sources", ["request_id"], :name => "index_request_funding_sources_on_request_id"
  add_index "request_funding_sources", ["sub_initiative_id"], :name => "request_funding_sources_sub_initiative_id"
  add_index "request_funding_sources", ["sub_program_id"], :name => "request_funding_sources_sub_program_id"

  create_table "request_geo_states", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id"
    t.integer  "geo_state_id"
  end

  add_index "request_geo_states", ["geo_state_id"], :name => "index_request_geo_states_on_geo_state_id"
  add_index "request_geo_states", ["request_id"], :name => "index_request_geo_states_on_request_id"

  create_table "request_organizations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id"
    t.integer  "organization_id"
    t.string   "description"
  end

  add_index "request_organizations", ["organization_id"], :name => "request_organizations_organization_id"
  add_index "request_organizations", ["request_id", "organization_id"], :name => "request_organizations_req_org_id", :unique => true

  create_table "request_programs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id"
    t.integer  "program_id"
    t.string   "state",               :default => "new"
    t.datetime "approved_at"
    t.integer  "approved_by_user_id"
  end

  add_index "request_programs", ["created_by_id"], :name => "request_programs_created_by_id"
  add_index "request_programs", ["program_id"], :name => "request_programs_program_id"
  add_index "request_programs", ["request_id", "program_id"], :name => "index_request_programs_on_request_id_and_program_id", :unique => true
  add_index "request_programs", ["updated_by_id"], :name => "request_programs_updated_by_id"

  create_table "request_reports", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id"
    t.integer  "approved_by_user_id"
    t.string   "state"
    t.string   "report_type",         :default => "RequestReport", :null => false
    t.integer  "evaluation_rating"
    t.text     "report"
    t.datetime "due_at"
    t.datetime "approved_at"
    t.integer  "locked_by_id"
    t.datetime "locked_until"
    t.datetime "deleted_at"
    t.boolean  "delta",               :default => true,            :null => false
  end

  add_index "request_reports", ["request_id"], :name => "index_request_reports_on_request_id"

  create_table "request_reviewer_assignments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id"
    t.integer  "user_id"
  end

  add_index "request_reviewer_assignments", ["created_by_id"], :name => "request_reviewer_assignments_created_by_id"
  add_index "request_reviewer_assignments", ["request_id"], :name => "request_reviewer_assignments_request_id"
  add_index "request_reviewer_assignments", ["updated_by_id"], :name => "request_reviewer_assignments_updated_by_id"
  add_index "request_reviewer_assignments", ["user_id"], :name => "request_reviewer_assignments_user_id"

  create_table "request_reviews", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id"
    t.integer  "rating"
    t.string   "review_type"
    t.text     "comment"
    t.text     "benefits"
    t.text     "outcomes"
    t.text     "merits"
    t.text     "recommendation"
    t.integer  "locked_by_id"
    t.datetime "locked_until"
    t.datetime "deleted_at"
    t.boolean  "conflict_reported"
    t.boolean  "delta",             :default => false
  end

  add_index "request_reviews", ["created_by_id"], :name => "request_reviews_created_by_id"
  add_index "request_reviews", ["updated_by_id"], :name => "request_reviews_updated_by_id"

  create_table "request_transaction_funding_sources", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_funding_source_id"
    t.integer  "request_transaction_id"
    t.decimal  "amount",                    :precision => 15, :scale => 2
  end

  add_index "request_transaction_funding_sources", ["created_by_id"], :name => "request_transaction_funding_sources_created_by_id"
  add_index "request_transaction_funding_sources", ["request_funding_source_id"], :name => "request_transaction_funding_sources_fundsrc_id"
  add_index "request_transaction_funding_sources", ["request_transaction_id"], :name => "request_transaction_funding_sources_transaction_id"
  add_index "request_transaction_funding_sources", ["updated_by_id"], :name => "request_transaction_funding_sources_updated_by_id"

  create_table "request_transactions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id"
    t.decimal  "amount_paid",                 :precision => 15, :scale => 2
    t.decimal  "amount_due",                  :precision => 15, :scale => 2
    t.datetime "due_at"
    t.datetime "paid_at"
    t.string   "comment"
    t.string   "payment_type"
    t.string   "payment_confirmation_number"
    t.integer  "payment_recorded_by_id"
    t.string   "state"
    t.integer  "locked_by_id"
    t.datetime "locked_until"
    t.datetime "deleted_at"
    t.boolean  "delta",                                                      :default => true, :null => false
    t.string   "request_document_linked_to"
    t.integer  "organization_payee_id"
    t.integer  "user_payee_id"
    t.integer  "bank_account_id"
    t.text     "condition"
    t.integer  "migrate_id"
  end

  add_index "request_transactions", ["organization_payee_id"], :name => "request_transactions_org_payee_id"
  add_index "request_transactions", ["payment_recorded_by_id"], :name => "index_request_transactions_on_payment_recorded_by_id"
  add_index "request_transactions", ["request_id"], :name => "index_request_transactions_on_request_id"
  add_index "request_transactions", ["user_payee_id"], :name => "request_transactions_user_payee_id"

  create_table "request_users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "request_id"
    t.integer  "user_id"
    t.string   "description"
  end

  add_index "request_users", ["request_id"], :name => "index_request_users_on_request_id"
  add_index "request_users", ["user_id"], :name => "index_request_users_on_user_id"

  create_table "requests", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "program_organization_id"
    t.integer  "fiscal_organization_id"
    t.integer  "program_id"
    t.integer  "sub_program_id"
    t.boolean  "granted",                                                          :default => false, :null => false
    t.boolean  "renewal_grant"
    t.boolean  "funding_general_operating_support"
    t.boolean  "board_authorization_required"
    t.datetime "request_received_at"
    t.datetime "grant_approved_at"
    t.datetime "grant_agreement_at"
    t.datetime "grant_begins_at"
    t.datetime "grant_closed_at"
    t.decimal  "amount_requested",                  :precision => 15, :scale => 2
    t.decimal  "amount_recommended",                :precision => 15, :scale => 2
    t.integer  "duration_in_months"
    t.text     "project_summary"
    t.string   "base_request_id"
    t.string   "fip_title"
    t.string   "fip_consultant_name"
    t.datetime "fip_projected_end_at"
    t.datetime "ierf_proposed_end_at"
    t.datetime "ierf_budget_end_at"
    t.text     "ierf_goals"
    t.text     "ierf_tactics"
    t.text     "ierf_probability"
    t.text     "ierf_due_diligence_overlap"
    t.text     "ierf_due_diligence_risks"
    t.text     "ierf_due_diligence_noc4_work"
    t.text     "ierf_due_diligence_board_review"
    t.decimal  "funds_expended_amount",             :precision => 15, :scale => 2
    t.datetime "funds_expended_at"
    t.string   "type"
    t.string   "state"
    t.integer  "locked_by_id"
    t.datetime "locked_until"
    t.datetime "deleted_at"
    t.boolean  "delta",                                                            :default => true,  :null => false
    t.integer  "fip_type_id"
    t.integer  "program_lead_id"
    t.integer  "fiscal_org_owner_id"
    t.integer  "grantee_signatory_id"
    t.integer  "fiscal_signatory_id"
    t.integer  "grantee_org_owner_id"
    t.integer  "initiative_id"
    t.integer  "sub_initiative_id"
    t.string   "po_number"
    t.boolean  "extension_flag"
    t.boolean  "display_warnings",                                                 :default => true
    t.integer  "grant_cycle_id"
    t.integer  "migrate_id"
    t.boolean  "skip_hgrant_flag",                                                 :default => false, :null => false
    t.integer  "reviewer_group_id"
  end

  add_index "requests", ["fiscal_org_owner_id"], :name => "index_requests_on_fiscal_org_owner_id"
  add_index "requests", ["fiscal_organization_id"], :name => "index_requests_on_fiscal_organization_id"
  add_index "requests", ["fiscal_signatory_id"], :name => "index_requests_on_fiscal_signatory_id"
  add_index "requests", ["granted"], :name => "index_requests_on_granted"
  add_index "requests", ["grantee_org_owner_id"], :name => "index_requests_on_grantee_org_owner_id"
  add_index "requests", ["grantee_signatory_id"], :name => "index_requests_on_grantee_signatory_id"
  add_index "requests", ["program_id"], :name => "index_requests_on_program_id"
  add_index "requests", ["program_lead_id"], :name => "index_requests_on_program_lead_id"
  add_index "requests", ["program_organization_id"], :name => "index_requests_on_program_organization_id"
  add_index "requests", ["sub_program_id"], :name => "index_requests_on_initiative_id"

  create_table "role_users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "user_id"
    t.integer  "roleable_id"
    t.integer  "role_id"
  end

  add_index "role_users", ["created_by_id"], :name => "role_users_created_by_id"
  add_index "role_users", ["role_id"], :name => "role_users_role_id"
  add_index "role_users", ["roleable_id"], :name => "index_role_users_on_name_and_roleable_type_and_roleable_id"
  add_index "role_users", ["roleable_id"], :name => "index_role_users_on_roleable_id"
  add_index "role_users", ["updated_by_id"], :name => "role_users_updated_by_id"
  add_index "role_users", ["user_id"], :name => "index_role_users_on_user_id"
  add_index "role_users", ["user_id"], :name => "index_role_users_on_user_id_and_roleable_type"

  create_table "roles", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name"
    t.string   "roleable_type"
    t.datetime "deleted_at"
  end

  add_index "roles", ["created_by_id"], :name => "roles_created_by_id"
  add_index "roles", ["updated_by_id"], :name => "roles_updated_by_id"

  create_table "sphinx_checks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "check_ts"
    t.boolean  "delta",      :default => true, :null => false
  end

  create_table "sub_initiatives", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name",                             :null => false
    t.text     "description"
    t.integer  "initiative_id",                    :null => false
    t.boolean  "retired",       :default => false, :null => false
    t.integer  "migrate_id"
  end

  add_index "sub_initiatives", ["created_by_id"], :name => "sub_initiatives_created_by_id"
  add_index "sub_initiatives", ["initiative_id"], :name => "sub_initiative_initiative_id"
  add_index "sub_initiatives", ["updated_by_id"], :name => "sub_initiatives_updated_by_id"

  create_table "sub_programs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name"
    t.string   "description"
    t.integer  "program_id"
    t.boolean  "retired",       :default => false, :null => false
    t.integer  "migrate_id"
  end

  add_index "sub_programs", ["program_id"], :name => "index_initiatives_on_program_id"

  create_table "user_organizations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "title",           :limit => 400
    t.string   "department",      :limit => 400
    t.string   "email",           :limit => 400
    t.string   "phone",           :limit => 400
    t.datetime "locked_until"
    t.integer  "locked_by_id"
  end

  add_index "user_organizations", ["created_by_id"], :name => "user_organizations_created_by_id"
  add_index "user_organizations", ["organization_id"], :name => "index_user_organizations_on_organization_id"
  add_index "user_organizations", ["updated_by_id"], :name => "user_organizations_updated_by_id"
  add_index "user_organizations", ["user_id"], :name => "index_user_organizations_on_user_id"

  create_table "user_permissions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "model_type"
    t.integer  "user_id"
    t.string   "name"
  end

  add_index "user_permissions", ["created_by_id"], :name => "user_permissions_created_by_id"
  add_index "user_permissions", ["updated_by_id"], :name => "user_permissions_updated_by_id"
  add_index "user_permissions", ["user_id"], :name => "user_permissions_user_id"

  create_table "user_profile_rules", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_profile_id"
    t.string   "permission_name"
    t.boolean  "allowed",         :default => true, :null => false
    t.string   "model_type"
  end

  add_index "user_profile_rules", ["permission_name"], :name => "index_user_profile_rules_on_role_name"
  add_index "user_profile_rules", ["user_profile_id"], :name => "user_profile_rules_user_profile_id"

  create_table "user_profiles", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "user_profiles", ["name"], :name => "index_user_profiles_on_name"

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.text     "roles_text"
    t.string   "login",                        :limit => 40
    t.string   "first_name",                   :limit => 400,  :default => ""
    t.string   "last_name",                    :limit => 400,  :default => ""
    t.string   "email",                        :limit => 250
    t.string   "personal_email",               :limit => 400
    t.string   "salutation",                   :limit => 400
    t.string   "prefix",                       :limit => 400
    t.string   "middle_initial",               :limit => 400
    t.string   "personal_phone",               :limit => 400
    t.string   "personal_mobile",              :limit => 400
    t.string   "personal_fax",                 :limit => 400
    t.string   "personal_street_address",      :limit => 400
    t.string   "personal_street_address2",     :limit => 400
    t.string   "personal_city",                :limit => 400
    t.integer  "personal_geo_state_id"
    t.integer  "personal_geo_country_id"
    t.string   "personal_postal_code",         :limit => 400
    t.string   "work_phone",                   :limit => 400
    t.string   "work_fax",                     :limit => 400
    t.string   "other_contact",                :limit => 400
    t.string   "assistant_name",               :limit => 400
    t.string   "assistant_phone",              :limit => 400
    t.string   "assistant_email",              :limit => 400
    t.string   "blog_url",                     :limit => 2048
    t.string   "twitter_url",                  :limit => 2048
    t.datetime "birth_at"
    t.string   "state",                                        :default => "passive"
    t.boolean  "delta",                                        :default => true
    t.datetime "deleted_at"
    t.string   "user_salutation",              :limit => 40
    t.integer  "primary_user_organization_id"
    t.datetime "last_logged_in_at"
    t.string   "time_zone",                    :limit => 40,   :default => "Pacific Time (US & Canada)"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
    t.string   "crypted_password",             :limit => 128,  :default => "",                           :null => false
    t.string   "password_salt",                                :default => "",                           :null => false
    t.string   "persistence_token"
    t.datetime "single_access_token"
    t.datetime "confirmation_sent_at"
    t.integer  "login_count",                                  :default => 0
    t.integer  "failed_login_count",                           :default => 0
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.integer  "user_profile_id"
    t.boolean  "test_user_flag",                               :default => false
    t.string   "linkedin_url"
    t.string   "facebook_url"
    t.integer  "migrate_id"
    t.string   "first_name_foreign_language",  :limit => 500
    t.string   "middle_name_foreign_language", :limit => 500
    t.string   "last_name_foreign_language",   :limit => 500
    t.string   "perishable_token"
    t.boolean  "active",                                       :default => true
    t.boolean  "approved",                                     :default => true
    t.boolean  "confirmed",                                    :default => true
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"
  add_index "users", ["personal_geo_country_id"], :name => "users_personal_country_id"
  add_index "users", ["personal_geo_state_id"], :name => "users_personal_geo_state_id"
  add_index "users", ["primary_user_organization_id"], :name => "users_primary_user_org_id"
  add_index "users", ["single_access_token"], :name => "index_users_on_single_access_token"
  add_index "users", ["user_profile_id"], :name => "users_user_profile_id"

  create_table "wiki_document_templates", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "model_type"
    t.string   "document_type"
    t.string   "filename"
    t.string   "description"
    t.string   "category"
    t.text     "document"
    t.datetime "deleted_at"
    t.boolean  "delta",         :default => true, :null => false
  end

  add_index "wiki_document_templates", ["category"], :name => "index_wiki_document_templates_on_category"
  add_index "wiki_document_templates", ["created_by_id"], :name => "wikdoctemplate_created_by_id"
  add_index "wiki_document_templates", ["document_type"], :name => "index_wiki_document_templates_on_document_type"
  add_index "wiki_document_templates", ["model_type"], :name => "index_wiki_document_templates_on_model_type"
  add_index "wiki_document_templates", ["updated_by_id"], :name => "wikdoctemplate_updated_by_id"

  create_table "wiki_documents", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "model_id"
    t.string   "model_type"
    t.integer  "wiki_order"
    t.string   "title"
    t.text     "note"
    t.datetime "deleted_at"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
    t.integer  "wiki_document_template_id"
  end

  add_index "wiki_documents", ["created_by_id"], :name => "wiki_documents_created_by_id"
  add_index "wiki_documents", ["updated_by_id"], :name => "wiki_documents_updated_by_id"
  add_index "wiki_documents", ["wiki_document_template_id"], :name => "wiki_documents_template_id"

  create_table "work_tasks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "name"
    t.text     "task_text"
    t.string   "taskable_type"
    t.integer  "taskable_id"
    t.datetime "due_at"
    t.integer  "task_order"
    t.integer  "assigned_user_id"
    t.boolean  "task_completed",   :default => false
    t.datetime "deleted_at"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
    t.datetime "completed_at"
  end

  add_index "work_tasks", ["assigned_user_id"], :name => "work_tasks_assigned_user_id"
  add_index "work_tasks", ["created_by_id"], :name => "work_tasks_created_by_id"
  add_index "work_tasks", ["updated_by_id"], :name => "work_tasks_updated_by_id"

  create_table "workflow_events", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "change_type"
    t.string   "workflowable_type"
    t.integer  "workflowable_id"
    t.string   "ip_address"
    t.string   "old_state"
    t.string   "new_state"
    t.text     "comment"
    t.string   "related_workflowable_type"
    t.integer  "related_workflowable_id"
  end

  add_index "workflow_events", ["created_by_id"], :name => "workflow_events_created_by_id"
  add_index "workflow_events", ["updated_by_id"], :name => "workflow_events_updated_by_id"
  add_index "workflow_events", ["workflowable_id", "workflowable_type"], :name => "workflow_events_flowid_type"

end
