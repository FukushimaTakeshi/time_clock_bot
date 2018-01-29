Rails.application.routes.draw do
  post '/callback', to: 'webhook#callback'

  root 'static_pages#home'

  get '/signup', to: 'users#edit'
  # post '/signup', to: 'users#create'
  patch '/signup', to: 'users#create'

  resources :users
  resources :account_activations, param: :token, only: [:edit]
end
