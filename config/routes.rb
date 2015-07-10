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

  resources :sessions, only: [:new] do
    collection do
      get  :dev_login
      post :dev_login
      delete :destroy
    end
  end

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
