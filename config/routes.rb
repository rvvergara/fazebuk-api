Rails.application.routes.draw do
  namespace :v1 do
    get 'facebook_authentications/create'
  end
  namespace :v1, defaults: { format: :json } do
    resources :sessions, only: [:create]
    resources :users, param: :username, only: [:show, :create, :update, :destroy]
    get '/auth/facebook', to: 'facebook_authentications#create'
    resources :users, param: :username, only: [:show, :create, :update, :destroy] do
      resources :friendships, only: [:create,:destroy]
      get '/friends', to: 'friendships#index'
    end
    resources :friendships, only: [:update]
  end
end
