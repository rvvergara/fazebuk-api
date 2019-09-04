Rails.application.routes.draw do
  namespace :v1 do
    get 'facebook_authentications/create'
  end
  namespace :v1, defaults: { format: :json } do
    resources :sessions, only: [:create]
    resources :users, param: :username, only: [:show, :create, :update, :destroy]
    get '/auth/facebook', to: 'facebook_authentications#create'
    resources :users, param: :username, only: [:show, :create, :update, :destroy] do
      resources :friends, only: [:index], module: :users
      resources :mutual_friends, only: [:index], module: :users
      resources :timeline_posts, only: [:index], module: :users
    end
    resources :friendships, only: [:create, :update, :destroy]
  end
end
