Rails.application.routes.draw do
  namespace :v1 do
    get 'facebook_authentications/create'
  end
  namespace :v1, defaults: { format: :json } do
    resources :sessions, only: [:create]
    resources :users, param: :username, only: [:show, :create, :update, :destroy]
    get '/auth/facebook', to: 'facebook_authentications#create'
    resources :users, param: :username, only: [:show, :create, :update, :destroy] do
      get '/friends', to: 'friends#all_friends'
      get '/mutual_friends', to: 'friends#mutual_friends'
    end
    resources :friendships, only: [:create, :update, :destroy]
  end
end
