Rails.application.routes.draw do
  namespace :v1 do
    get 'facebook_authentications/create'
  end
  namespace :v1, defaults: { format: :json } do
    resources :sessions, only: [:create]
    resources :users, param: :username, only: [:show, :create, :update, :destroy]
    get '/auth/facebook', to: 'facebook_authentications#create'
    resources :users, param: :username, only: [:show, :create, :update, :destroy] do
      resources :friendships, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
