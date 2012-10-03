Rails.application.routes.draw do
  resources :multi_element_values

  resources :multi_element_groups

  resources :admin_items

  resources :admin_cards
  resources :user_permissions

  resources :roles

  resources :modules

  resources :work_tasks

  resources :bank_accounts

  resources :favorites
  resources :geo_countries
  resources :groups
  resources :model_documents
  resources :model_document_types
  resources :documents
  resources :organizations
  resources :user_organizations
  resources :geo_cities
  resources :geo_states
  resources :group_members
  resources :notes
  resources :role_users
  resources :users
  resources :projects
  resources :project_lists
  resources :project_list_items
  resources :project_users
  resources :project_organizations
  resources :wiki_documents
  resources :wiki_document_templates
  resources :model_document_templates
  resources :alerts
end

