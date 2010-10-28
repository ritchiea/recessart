FluxxGrantRi::Application.routes.draw do
  resources :hgrants
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
end
