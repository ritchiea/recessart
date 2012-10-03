Rails.application.routes.draw do
  resources :lois

  resources :budget_requests

  resources :request_reviews

  resources :reviewer_portal

  resources :funding_source_allocation_authorities

  resources :request_transaction_funding_sources

  resources :modal_reports

  resources :request_programs

  resources :funding_sources

  resources :admin_cards

  resources :funding_source_allocations

  resources :sub_initiatives

  resources :sub_programs

  resources :request_funding_sources
  resources :request_evaluation_metrics
  resources :request_transactions
  resources :grant_requests do
    put :hide_funding_warnings, :on => :member
  end
  resources :fip_requests
  resources :request_letters
  resources :request_users
  resources :request_projects
  resources :granted_requests
  resources :request_organizations
  resources :programs
  resources :initiatives
  resources :request_reports
  resources :project_requests
  resources :outside_grants
  resources :grantee_portal
  resources :portal_grant_requests

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'portal', :controller => :user_sessions
end
