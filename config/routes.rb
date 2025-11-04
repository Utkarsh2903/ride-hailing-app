Rails.application.routes.draw do
  # Swagger API Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
  get "health" => "rails/health#show"

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      get 'auth/me', to: 'auth#me'
      post 'auth/logout', to: 'auth#logout'

      # Tenants (Super Admin only)
      resources :tenants, only: [:index, :show, :create, :update, :destroy] do
        member do
          get :stats
        end
      end

      # Rides
      resources :rides, only: [:create, :show, :index] do
        member do
          post :cancel
          get :track
        end
      end

      # Drivers
      resources :drivers, only: [] do
        member do
          post :update_location, path: 'location'
          post :batch_update_location, path: 'location/batch'
          post :accept, path: 'accept'
          post :decline, path: 'decline'
          post :mark_arrived, path: 'arrive'
          post :start_trip, path: 'start_trip'
          post :go_online, path: 'online'
          post :go_offline, path: 'offline'
          get :earnings
        end
      end

      # Trips
      resources :trips, only: [:show] do
        member do
          post :end_trip, path: 'end'
        end
      end

      # Payments
      resources :payments, only: [:create, :show, :index] do
        member do
          post :retry_payment, path: 'retry'
          post :refund
        end
      end
    end
  end
end
