Rails.application.routes.draw do
  root to: 'pages#index'
  resources :permits, only: [:index]
end
