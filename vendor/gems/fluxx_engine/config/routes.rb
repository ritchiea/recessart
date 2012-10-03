Rails.application.routes.draw do
  resources :realtime_updates
  resources :multi_element_values
  resources :client_stores
  match 'dashboard', :to => 'dashboard#index'
  get "dashboard/index"
  get "dashboard/example_partial_update"
  root :to => 'dashboard#index'
  resources :user_sessions
end
