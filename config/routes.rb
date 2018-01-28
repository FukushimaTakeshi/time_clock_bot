Rails.application.routes.draw do
  post '/callback', to: 'webhook#callback'

  root 'static_pages#home'

  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  resources :users
  resources :account_activations, param: :token, only: [:edit]
end
