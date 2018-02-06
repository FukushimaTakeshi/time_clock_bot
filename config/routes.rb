Rails.application.routes.draw do
  root to: 'home#index'

  post '/callback', to: 'webhook#callback'

  # root 'static_pages#home'

  get '/signup/:id', to: 'users#new', as: 'new_signup'
  patch '/signup/:id', to: 'users#update', as: 'update_signup'

  resources :users
  resources :account_activations, param: :token, only: [:edit]

  get '*unmatched_route', to: 'application#render_404'
end
