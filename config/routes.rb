Rails.application.routes.draw do
  resource :session, only: %i[new create destroy]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Root route
  root "projects#index"

  # Projects with nested tasks
  resources :projects do
    resources :tasks, except: [ :index ]
    member do
      patch :archive
    end
  end

  # Task dependencies (AJAX only)
  resources :task_dependencies, only: [ :create, :destroy ]

  # Tasks can also be accessed directly for certain actions
  resources :tasks, only: [ :index, :show ] do
    member do
      patch :complete
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
