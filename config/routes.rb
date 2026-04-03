Rails.application.routes.draw do
  devise_for :users

  root "dashboard#index"

  resources :projects do
    member do
      get :board
      get :settings
    end

    resources :tickets, only: %i[new create]
    resources :labels, only: %i[index create update destroy]
    resources :memberships, only: %i[index create destroy], controller: "project_memberships"
  end

  resources :tickets, only: %i[show edit update destroy] do
    resources :comments, only: %i[create destroy]
    resources :pr_links, only: %i[create destroy]
    resources :ticket_relationships, only: %i[create destroy]

    member do
      patch :transition
      patch :reorder
      patch :assign
    end
  end

  get "my_tickets", to: "tickets#my_tickets"
  get "agents", to: "agent_dashboard#index"
  get "agents/:id", to: "agent_dashboard#show", as: :agent
  resource :profile, only: %i[show edit update]

  resources :notifications, only: [:index] do
    member do
      patch :mark_as_read
    end

    collection do
      patch :mark_all_as_read
    end
  end

  namespace :api do
    namespace :v1 do
      resources :projects, only: %i[index show] do
        resources :tickets, only: [:index], controller: 'project_tickets'
      end

      resources :tickets, only: %i[show create] do
        member do
          patch :assign
          patch :transition
        end

        resources :comments, only: [:create], module: :tickets
        resources :pr_links, only: [:create], module: :tickets
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

end
