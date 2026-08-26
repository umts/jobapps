Rails.application.routes.draw do
  root 'dashboard#main'

  get '/auth/:provider/callback', to: 'sessions#create', as: :auth_callback
  post '/logout', to: 'sessions#destroy'

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

  resources :departments, except: [:index, :show]

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

  resources :users, except: [:index, :show] do
    collection do
      get :promote
      put :promote_save
    end
  end

  direct :azure_login do
    '/auth/entra_id'
  end

  direct :azure_logout do
    tenant_id = Rails.application.credentials.dig(:entra_id, :tenant_id)
    redirect_uri = CGI.escape(root_url)
    "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/logout?post_logout_redirect_uri=#{redirect_uri}"
  end
end
