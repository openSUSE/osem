Osem::Application.routes.draw do

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  if ENV['OSEM_ICHAIN_ENABLED'] == 'true'
    devise_for :users, controllers: { registrations: :registrations }
  else
    devise_for :users,
               controllers: {
                   registrations: :registrations, confirmations: :confirmations,
                   omniauth_callbacks: 'users/omniauth_callbacks' },
               path:        'accounts'
  end

  resources :users, except: [:new, :index, :create, :destroy] do
    resources :openids, only: :destroy
  end

  namespace :admin do
    resources :organizations do
      member do
        get :admins
        post :assign_org_admins
        delete :unassign_org_admins
      end
    end
    resources :users do
      member do
        patch :toggle_confirmation
      end
    end
    resource :ticket_scanning, only: [:create]
    resources :comments, only: [:index]
    resources :conferences do
      resources :surveys do
        resources :survey_questions, except: :index
      end
      resource :contact, except: [:index, :new, :create, :show, :destroy]
      resources :schedules, except: [:edit, :update]
      resources :event_schedules, only: [:create, :update, :destroy]
      get 'commercials/render_commercial' => 'commercials#render_commercial'
      resources :commercials, only: [:index, :create, :update, :destroy]
      get '/volunteers_list' => 'volunteers#show'
      get '/volunteers' => 'volunteers#index', as: 'volunteers_info'
      patch '/volunteers' => 'volunteers#update', as: 'volunteers_update'

      resources :booths do
        member do
          patch :accept
          patch :restart
          patch :to_accept
          patch :reject
          patch :reset
          patch :to_reject
          patch :cancel
          patch :confirm
        end
      end

      resources :registrations, except: [:create, :new] do
        member do
          patch :toggle_attendance

        end
      end

      # Singletons
      resource :splashpage
      resource :venue do
        get 'venue_commercial/render_commercial' => 'venue_commercials#render_commercial'
        resource :venue_commercial, only: [:create, :update, :destroy]
        resources :rooms, except: [:show]
      end
      resource :registration_period
      resource :program do
        resources :cfps
        resources :tracks do
          member do
            patch :toggle_cfp_inclusion
            patch :restart
            patch :to_accept
            patch :accept
            patch :confirm
            patch :to_reject
            patch :reject
            patch :cancel
            patch :update_selected_schedule
          end
          resources :roles, only: [:show, :edit, :update] do
            member do
              post :toggle_user
            end
          end
        end
        resources :event_types
        resources :difficulty_levels
        post 'mass_upload_commercials' => 'commercials#mass_upload'
        resources :events do
          member do
            patch :toggle_attendance
            get :registrations
            post :comment
            patch :accept
            patch :confirm
            patch :cancel
            patch :reject
            patch :unconfirm
            patch :restart
            get :vote
          end
        end
        resources :reports, only: :index
      end

      resources :resources
      resources :tickets do
        member do
          post :give
        end
      end
      resources :sponsors, except: [:show]
      resources :lodgings, except: [:show]
      resources :emails, only: [:show, :update, :index]
      resources :physical_tickets, only: [:index]
      resources :roles, except: [:new, :create] do
        member do
          post :toggle_user
        end
      end

      resources :sponsorship_levels, except: [:show] do
        member do
          patch :up
          patch :down
        end
      end

      resources :questions do
        collection do
          patch :update_conference
        end
      end

      get '/revision_history' => 'versions#index'
    end

    get '/revision_history' => 'versions#index'
    get '/revision_history/:id/revert_object' => 'versions#revert_object', as: 'revision_history_revert_object'
    get '/revision_history/:id/revert_attribute' => 'versions#revert_attribute', as: 'revision_history_revert_attribute'
  end
  resources :organizations, only: [:index] do
    member do
      get :conferences, 'code-of-conduct'
    end
  end
  resources :conferences, only: [:index, :show] do
    resources :booths do
      member do
        patch :withdraw
        patch :confirm
        patch :restart
      end
    end
    resources :surveys, only: [:index, :show] do
      member do
        post :reply
      end
    end
    resource :program, only: [] do
      get 'proposal/:id', to: 'proposals#show' # For backward compatibility
      resources :proposals, except: :destroy do
        get 'commercials/render_commercial' => 'commercials#render_commercial'
        resources :commercials, only: [:create, :update, :destroy]
        member do
          get :registrations
          patch '/withdraw' => 'proposals#withdraw'
          patch '/confirm' => 'proposals#confirm'
          patch '/restart' => 'proposals#restart'
        end
      end
      resources :tracks, except: :destroy do
        member do
          patch :restart
          patch :confirm
          patch :withdraw
        end
      end
    end

    # TODO: change conference_registrations to singular resource
    resource :conference_registration, path: 'register'
    resources :tickets, only: [:index]
    resources :ticket_purchases, only: [:create, :destroy, :index]
    resources :payments, only: [:index, :new, :create]
    resources :physical_tickets, only: [:index, :show]
    resource :subscriptions, only: [:create, :destroy]
    resource :schedule, only: [:show] do
      collection do
        get 'app'
      end
      member do
        get :events
        get :happening_now
      end
    end
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :conferences, only: [ :index, :show ] do
        resources :rooms, only: :index
        resources :tracks, only: :index
        resources :speakers, only: :index
        resources :events, only: :index
      end
      resources :rooms, only: :index
      resources :tracks, only: :index
      resources :speakers, only: :index
      resources :events, only: :index
    end
  end

  get '/admin' => redirect('/admin/conferences')

  unless ENV['OSEM_ROOT_CONFERENCE'].blank?
    root to: redirect("/conferences/#{ENV['OSEM_ROOT_CONFERENCE']}")
  else
    root to: 'conferences#index', via: [:get, :options]
  end

  constraints DomainConstraint do
    root to: 'conferences#show'
  end

  get '/.well-known/apple-developer-merchantid-domain-association', to: 'application#apple_pay'
end
