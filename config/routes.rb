Osem::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => :registrations }, :path => 'accounts'

  namespace :admin do
    resources :users
    resources :people
    resources :conference do
      get "/schedule" => "schedule#show"
      put "/schedule" => "schedule#update"
      get "/stats" => "stats#index"
      get "/registrations" => "registrations#show"
      get "/registrations/new" => "registrations#new"
      put "/registrations/new" => "registrations#create"
      get "/registrations/edit" => "registrations#edit"
      put "/registrations/edit" => "registrations#update"
      delete "/registrations"  => "registrations#delete"
      put "/registrations/change_field" => "registrations#change_field"
      get "/venue" => "venue#show", :as => "venue_info"
      put "/venue" => "venue#update", :as => "venue_update"
      get "/dietary_choices" => "dietchoices#show", :as => "dietary_list"
      put "/dietary_choices" => "dietchoices#update", :as => "dietary_update"
      get "/volunteers_list" => "volunteers#show"
      get "/volunteers" => "volunteers#index", :as => "volunteers_info"
      put "/volunteers" => "volunteers#update", :as => "volunteers_update"

      resources :difficulty_levels, only: [:show, :update, :index]
      resources :rooms, only: [:show, :update, :index]
      resources :tracks, only: [:show, :update, :index]
      resources :eventtypes, only: [:show, :update, :index]
      resources :social_events, only: [:show, :update, :index]
      resources :supporter_levels, only: [:show, :update, :index]
      resources :emails, only: [:show, :update, :index]
      resources :callforpapers, only: [:show, :update, :index]
      put "/questions/update_conference" => "questions#update_conference"
      resources :questions
      resources :events do
        member do
          post :comment
          put :update_state
          put :update_track
          get :vote
        end
        resource :speaker, :only => [:edit, :update]
      end
      resources :supporters
    end
  end

  resources :conference, :only => [] do
    get '/show' => 'conference#show'
    resources :proposal do
      resources :event_attachment, :controller => "event_attachments"
      put "/confirm" => "proposal#confirm"
    end
    resource :schedule, :only => [] do
      get "/" => "schedule#index"
    end
    member do
      get "/register" => "conference_registration#register"
      put "/register" => "conference_registration#update"
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
