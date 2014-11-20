Osem::Application.routes.draw do

  if CONFIG['authentication']['ichain']['enabled']
    devise_for :users, controllers: { registrations: :registrations }
  else
    devise_for :users,
               controllers: {
                   registrations: :registrations,
                   omniauth_callbacks: 'users/omniauth_callbacks' },
               path: 'accounts'
  end

  resources :users, except: [:new, :index, :create, :destroy]

  namespace :admin do
    resources :users
    resources :people
    resources :conference do
      member do
        get :roles
        post :roles
        post :add_user
        delete :remove_user
      end
      resource :contact, except: [:index, :new, :create, :show, :destroy]
      resources :photos, except: [:show]
      resource :schedule, only: [:show, :update]
      resources :commercials, except: [:show]
      get '/stats' => 'stats#index'
      get '/dietary_choices' => 'dietchoices#show', as: 'dietary_list'
      patch '/dietary_choices' => 'dietchoices#update', as: 'dietary_update'
      get '/volunteers_list' => 'volunteers#show'
      get '/volunteers' => 'volunteers#index', as: 'volunteers_info'
      patch '/volunteers' => 'volunteers#update', as: 'volunteers_update'

      patch '/registrations/toogle_attended' => 'registrations#toogle_attended'
      resources :registrations, except: [:create, :new]

      resource :registration_period

      resource :splashpage

      resource :venue

      resources :difficulty_levels, only: [:show, :update, :index]

      resources :rooms, except: [:show]

      resources :tracks, only: [:show, :update, :index]

      resources :sponsorship_levels, except: [:show] do
	member do
	  patch :up
	  patch :down
	end
      end

      resources :sponsors, only: [:show, :update, :index]

      resources :lodgings

      resources :targets, only: [:update, :index]

      resources :campaigns

      resources :event_types, only: [:show, :index] do
        collection do
          patch :update
        end
      end

      resources :social_events, only: [:show, :update, :index]

      resources :tickets

      resources :emails, only: [:show, :update, :index]

      resources :callforpapers, only: [:create] do
        collection do
          patch :update
          get :show
        end
      end

      patch '/questions/update_conference' => 'questions#update_conference'
      resources :questions

      resources :events do
        member do
          post :comment
          patch :accept
          patch :confirm
          patch :cancel
          patch :reject
          patch :unconfirm
          patch :restart
          get :vote
        end
        resource :speaker, only: [:edit, :update]
      end
    end
  end

  resources :conference, only: [:index, :show] do
    resources :proposal do
      resources :commercials, except: [:show, :index]
      resources :event_attachment, controller: 'event_attachments'
      member do
        patch '/confirm' => 'proposal#confirm'
        patch '/restart' => 'proposal#restart'
      end
    end

    resource :conference_registrations, path: 'register'
    resources :tickets, only: [:index]
    resources :ticket_purchases, only: [:create, :destroy]
    resource :subscriptions, only: [:create, :destroy]

    resource :schedule, only: [] do
      get '/' => 'schedule#index'
    end

    member do
      get 'gallery_photos'
    end
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :conferences, only: :index do
        resources :conferences, only: :index
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

  get '/admin' => redirect('/admin/conference')

  root to: 'conference#index', via: [:get, :options]
end
