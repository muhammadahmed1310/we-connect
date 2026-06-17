Rails.application.routes.draw do
  # config/routes.rb
  # config/routes.rb
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords'
  }, skip: [:registrations]
  namespace :admin do
    get '/', to: 'control_panel#choices', as: :control_panel
    get 'choices', to: 'control_panel#choices'
    get 'logs', to: 'control_panel#logs'
  end

  resources :versions, only: [] do
    member do
      get :bulk_show, to: 'bulk_versions#show'
    end
  end


  get 'bulk_versions/:id', to: 'bulk_versions#show', as: :bulk_version

  resources :users do
    member do
      get  :password_modal
      patch :update_password
    end
  end


  # For items that can be sorted by dragging and dropping
  concern :positioned do
    post 'reorder', on: :collection
  end


  # For items that have paper_trail versions
  concern :versions do
    get 'versions', on: :member
  end
  post 'users/change_role', to: 'users#change_role'
  post 'users/bulk_action', to: 'users#bulk_action'
  post 'expeditions/:expedition_id/activities/bulk_action', to: 'activities#bulk_action', as: 'bulk_action_expedition_activities'
  post 'expeditions/:expedition_id/users/change_role', to: 'expedition_users#change_role', as: :change_role_expedition_users

  resources :choices, shallow: true do
    resources :choice_items, concerns: :positioned do
      collection do
        post :bulk_action
      end
    end
    collection do
      post :bulk_action
    end
  end

  resources :choice_items, only: [:index, :show, :edit, :update, :destroy], concerns: :positioned do
    collection do
      post :bulk_action
    end
  end


  resources :users, concerns: :versions do
    collection do
      post :bulk_action
      post :change_role
      get :index, defaults: { format: :html }
      get :index, defaults: { format: :xlsx }
    end
    resources :expedition_users
    resources :locations
    resources :contents
    resources :activities
    post :batch_upload, on: :collection, to: 'batch_upload'
  end


  resources :expeditions, shallow: true, concerns: :versions do
    collection do
      get :index, defaults: {format: :html}
      get :index, defaults: {format: :xlsx}
    end

    get 'tasks', on: :member
    resources :activities, path: 'tasks', activity_type: 'task', as: 'tasks', shallow: true do
      post :bulk_action, on: :collection
    end


    resources :users, controller: 'expedition_users' do
      collection do
        get :index, defaults: {format: :html}
        get :index, defaults: {format: :xlsx}
        post :bulk_action
        post :change_role
      end
    end

    post :bulk_action, on: :collection
    resources :organisations, only: [:create]  # used by the quick-add modal
    resources :activities, shallow: true
    resources :expedition_contents
    resources :expedition_organisations
    resources :expedition_phases
    resources :expedition_users
    resources :survey_expeditions
    resources :meetings, controller: 'activities', activity_type: 'meeting'
    resources :contents
    resources :surveys

    post :batch_upload, on: :collection, to: 'batch_upload'
    post :skeleton, on: :collection, to: 'create_from_skeleton'
  end

  #post 'expeditions/:expedition_id/users/change_role', to: 'expedition_users#change_role', as: :change_role_expedition_users



  resources :expedition_phases, shallow: true do
    resources :activities
    resources :tasks, controller: 'activities', activity_type: 'task'
    resources :meetings, controller: 'activities', activity_type: 'meeting'
  end
  resources :organisations do
    resources :users, only: [:index]        # parent-scoped index
    resources :expeditions, only: [:index]  # parent-scoped index
    collection do
      post :bulk_action
    end
  end
  resources :activities, shallow: true, concerns: :versions do
    collection do
      get :index, defaults: { format: :html }
      get :index, defaults: { format: :xlsx }
    end

    post :bulk_action, on: :collection
    resources :activity_contents
    resources :survey_activities
  end

  resources :contents, shallow: true, concerns: :versions do
    resources :activity_contents
    resources :expedition_contents
  end
  resources :locations, shallow: true, concerns: :versions do
    resources :expeditions
    resources :activities
  end
  resources :surveys, shallow: true, concerns: :versions do
    resources :survey_pages
    resources :survey_responses
    resources :survey_questions
    resources :survey_answers
  end
  resources :survey_pages, shallow: true, concerns: :versions do
    resources :survey_questions
  end
  resources :survey_questions, shallow: true, concerns: :versions do
    resources :survey_answers
    resources :survey_responses
  end
  resources :survey_responses, shallow: true, concerns: :versions do
    resources :survey_answers
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  root to: 'home#dashboard'
end
