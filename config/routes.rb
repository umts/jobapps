Rails.application.routes.draw do
  root 'sessions#create'

  resources :application_templates, only: [:edit, :show]

  resources :application_records, only: [:create, :show] do
    member do
      post :review
    end
  end

  resource :dashboard, controller: :dashboard do
    collection do
      get  :staff
      get  :student
    end
  end

  resources :interviews, only: [:create, :show]
  
  resources :questions, only: [:create, :update] do
    member do
      post :move
    end
  end

  resources :sessions, only: [:create] do
    collection do
      case Rails.env
      when 'development'
        get  :dev_login
        post :dev_login
      when 'production', 'test'
        #something something Shibboleth?
      end
      delete :destroy
    end
  end

  resources :site_texts, only: [:edit, :update] do
    collection do
      get  :request_new
      post :request_new
    end
  end
  
end
