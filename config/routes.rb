Osem::Application.routes.draw do

  get 'conference/show'

  devise_for :users, controllers: { registrations: :registrations }, path: 'accounts'

  namespace :admin do
    resources :users
    resources :people
    resources :conference do
      resource :schedule, only: [:show, :update]
      get '/stats' => 'stats#index'
      get '/venue' => 'venue#show', as: 'venue_info'
      patch '/venue' => 'venue#update', as: 'venue_update'
      get '/dietary_choices' => 'dietchoices#show', as: 'dietary_list'
      patch '/dietary_choices' => 'dietchoices#update', as: 'dietary_update'
      get '/volunteers_list' => 'volunteers#show'
      get '/volunteers' => 'volunteers#index', as: 'volunteers_info'
      patch '/volunteers' => 'volunteers#update', as: 'volunteers_update'

      patch '/registrations/change_field' => 'registrations#change_field'
      resources :registrations

      resources :difficulty_levels, only: [:show, :update, :index]

      resources :rooms, only: [:show, :update, :index]

      resources :tracks, only: [:show, :update, :index]

      resources :sponsorship_levels, only: [:show, :update, :index]

      resources :sponsors, only: [:show, :update, :index]

      resources :lodgings, only: [:show, :update, :index]

      resources :eventtypes, only: [:show, :index] do
        collection do
          patch :update
        end
      end

      resources :social_events, only: [:show, :update, :index]

      resources :supporter_levels, only: [:show, :update, :index]

      resources :emails, only: [:show, :update, :index]

      resources :callforpapers, only: [:create] do
        collection do
          patch :update
          get :show
        end
      end

      patch "/questions/update_conference" => "questions#update_conference"
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
        resource :speaker, :only => [:edit, :update]
      end

      resources :supporters
    end
  end

  resources :conference, only: [:show] do
    resources :proposal do
      resources :event_attachment, :controller => "event_attachments"
      patch '/confirm' => 'proposal#confirm'
      patch '/restart' => 'proposal#restart'
    end
    resource :schedule, :only => [] do
      get "/" => "schedule#index"
    end
    member do
      get "/register" => "conference_registration#register"
      patch "/register" => "conference_registration#update"
      delete "/register" => "conference_registration#unregister"
    end
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :conferences, :only => :index do
        resources :conferences, :only => :index
        resources :rooms, :only => :index
        resources :tracks, :only => :index
        resources :speakers, :only => :index
        resources :events, :only => :index
      end
      resources :rooms, :only => :index
      resources :tracks, :only => :index
      resources :speakers, :only => :index
      resources :events, :only => :index
    end
  end

  get "/admin" => redirect("/admin/conference")

  root :to => "home#index"
end
