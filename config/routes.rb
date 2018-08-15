Rails.application.routes.draw do
  resources :projects
  resources :tasks
  resources :user_sessions
  root to: "tasks#main"

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
end
