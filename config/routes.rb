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
      get "/emailsettings" => "emails#show", :as => "email_settings"
      put "/emailsettings" => "emails#update", :as => "email_settings"
      get "/supporter_levels" => "SupporterLevels#show"
      put "/supporter_levels" => "SupporterLevels#update"
      get "/venue" => "venue#show", :as => "venue_info"
      put "/venue" => "venue#update", :as => "venue_update"
      get "/social_events" => "SocialEvents#show", :as => "social_events"
      put "/social_events" => "SocialEvents#update", :as => "social_events"
      get "/rooms" => "rooms#show", :as => "rooms_list"
      put "/rooms" => "rooms#update", :as => "rooms_update"
      get "/tracks" => "tracks#show", :as => "tracks_list"
      put "/tracks" => "tracks#update", :as => "tracks_update"
      get "/dietary_choices" => "dietchoices#show", :as => "dietary_list"
      put "/dietary_choices" => "dietchoices#update", :as => "dietary_update"
      get "/cfp" => "callforpapers#show", :as => "cfp_info"
      put "/cfp" => "callforpapers#update", :as => "cfp_update"
      post "/cfp" => "callforpapers#create", :as => "cfp_create"
      get "/event_types" => "eventtype#show", :as => "eventtype_list"
      put "/event_types" => "eventtype#update", :as => "eventtype_update"
      put "/difficulty_levels" => "difficulty_levels#update"
      resources :difficulty_levels
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
    resources :proposal do
      resources :event_attachment, :controller => "EventAttachments"
      put "/confirm" => "proposal#confirm"
    end
    resource :schedule, :only => [] do
      get "/" => "schedule#index"
    end
    member do
      get "/register" => "ConferenceRegistration#register"
      put "/register" => "ConferenceRegistration#update"
      delete "/register" => "ConferenceRegistration#unregister"
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

  match "/admin" => redirect("/admin/conference")

  root :to => "home#index"
end
