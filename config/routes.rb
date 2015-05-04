Rails.application.routes.draw do
  root to: 'pages#index'
  get '/file', to: 'pages#file'
  #get '/marker', to: 'pages#index'
  #get '/cluster', to: 'pages#index'
end
