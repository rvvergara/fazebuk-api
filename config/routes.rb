Rails.application.routes.draw do
  namespace :v1, defaults: { format: :json } do
    resources :sessions, only: [:create]
    resources :users, param: :username, only: [:show, :create, :update, :destroy]
    get '/facebook/auth', to: 'facebook_authentications#create'
  end
end
