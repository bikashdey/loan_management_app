require 'sidekiq/web'
Rails.application.routes.draw do

  # # Devise routes for ActiveAdmin admin users
  devise_for :admin_users, ActiveAdmin::Devise.config

  # # ActiveAdmin routes
  ActiveAdmin.routes(self)
  mount Sidekiq::Web => '/sidekiq'

  # # Root and other resources
  # root to: "home#index"

  # Loan management
  resources :loans, only: [:create] do
    member do
      patch :update_loan
      put :repay
    end
  end

  # User-specific routes
    
  post '/login', to: 'users#login'
  resources :users, only: [:create ,:show, :update] do
    collection do
      get :user_loans
    end
  end
end
