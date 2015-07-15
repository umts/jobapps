Rails.application.routes.draw do
  if Rails.env.development?
    root 'sessions#dev_login'
  else root 'dashboard#main'
  end

  resources :application_templates, only: [:new, :edit, :show]

  resources :application_records, only: [:create, :show] do
    member do
      post :review
    end
  end

  get '/bus', to: 'application_templates#bus', as: :bus_application

  get '/dashboard/main',    to: 'dashboard#main',    as: :main_dashboard
  get '/dashboard/staff',   to: 'dashboard#staff',   as: :staff_dashboard
  get '/dashboard/student', to: 'dashboard#student', as: :student_dashboard

  resources :departments, except: [:index, :show]

  resources :interviews, only: :show do
    member do
      post :complete
      post :reschedule
    end
  end

  resources :positions, except: [:index, :show]
  
  resources :questions, only: [:create, :destroy, :update] do
    member do
      post :move
    end
  end

  # sessions
  unless Rails.env.production?
    get  'sessions/dev_login', to: 'sessions#dev_login', as: :dev_login
    post 'sessions/dev_login', to: 'sessions#dev_login'
  end
  get 'sessions/unauthenticated', to: 'sessions#unauthenticated', as: :unauthenticated_session
  get 'sessions/destroy', to: 'sessions#destroy', as: :destroy_session

  resources :site_texts, only: [:edit, :update] do
    collection do
      get  :request_new
      post :request_new
    end
    member do
      post :edit#for previewing changes
    end
  end

  resources :users, except: [:index, :show]
  
end
