Rails.application.routes.draw do
  post '/callback', to: 'webhook#callback'

  root 'static_pages#home'

  get '/signup/:id', to: 'users#new'
  patch '/signup/:id', to: 'users#update', as: 'signup'

  resources :users
  resources :account_activations, param: :token, only: [:edit]

  get '*unmatched_route', to: 'application#render_404'
end
