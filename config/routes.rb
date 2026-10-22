Rails.application.routes.draw do
  root 'dashboard#main'

  get '/up' => 'rails/health#show', as: :rails_health_check

  resources :application_templates, as: :applications, path: :applications, only: [:new, :show] do
    member do
      post :toggle_active
      post :toggle_eeo_enabled
      post :toggle_unavailability_enabled
      post :toggle_resume_upload_enabled
    end
  end

  resources :application_drafts, as: :drafts, except: [:create, :index] do
    member do
      post :update_application_template
    end
  end

  resources :application_submissions, only: [:create, :show] do
    collection do
      get :csv_export
      get :past_applications
      get :eeo_data
    end
    member do
      patch :review
      post :unreject
      patch :toggle_saved_for_later
      get  :print
    end
  end

  get '/dashboard/main',    to: 'dashboard#main',    as: :main_dashboard
  get '/dashboard/staff',   to: 'dashboard#staff',   as: :staff_dashboard
  get '/dashboard/student', to: 'dashboard#student', as: :student_dashboard

  resources :interviews, only: :show do
    member do
      post :complete
      post :reschedule
    end
  end

  mount MaintenanceTasks::Engine, at: '/maintenance_tasks'

  resources :positions, except: [:index, :show] do
    member do
      get :saved_applications
    end
  end

  resources :subscriptions

  get 'markdown/explanation'
  post 'markdown/explanation'

  resources :users, except: [:index, :show]
end
