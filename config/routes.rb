Rails.application.routes.draw do
  root 'sessions#create'

  resources :application_templates, only: [:edit]

  resource :dashboard, controller: :dashboard do
    collection do
      get  :application_templates
      get  :staff
      get  :student
    end
  end
  
  resources :questions, only: [:create, :update]

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

  resources :site_texts, only: [:edit]
  
end
