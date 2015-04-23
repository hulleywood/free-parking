Rails.application.routes.draw do
  root to: 'pages#index'
  get 'permit_kml', to: 'pages#permit_kml'
end
