Rails.application.routes.draw do
  if Rails.env.development?
    root 'sessions#dev_login'
  else root 'dashboard#main'
  end

  resources :application_templates, as: :applications, path: :applications, only: [:new, :show] do
    member do
      post :toggle_active
      post :toggle_eeo_enabled
      post :toggle_unavailability_enabled
    end
  end

  resources :application_drafts, as: :drafts, except: [:create, :index] do
    member do
      post :move_question
      post :remove_question
      post :update_application_template
    end
  end

  resources :application_records, only: [:create, :show] do
    collection do
      get :csv_export
      get :past_applications
      get :eeo_data
    end
    member do
      post :review
      post :toggle_saved_for_later
      get  :print
    end
  end

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

  resources :positions, except: [:index, :show] do
    member do
      get :saved_applications
    end
  end

  resources :subscriptions

  # sessions
  unless Rails.env.production?
    get  'sessions/dev_login', to: 'sessions#dev_login', as: :dev_login
    post 'sessions/dev_login', to: 'sessions#dev_login'
  end
  get 'sessions/unauthenticated', to: 'sessions#unauthenticated', as: :unauthenticated_session
  get 'sessions/destroy', to: 'sessions#destroy', as: :destroy_session

  resources :site_texts, only: [:edit, :show, :update] do
    collection do
      get  :request_new
      post :request_new
    end
    member do
      post :edit # for previewing changes
    end
  end

  resources :users, except: [:index, :show] do 
    collection do
      get :promote
      post :promote_save
    end
  end
end
