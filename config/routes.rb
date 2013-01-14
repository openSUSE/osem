Osem::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => :registrations }, :path => 'accounts'

  namespace :admin do
    resources :users
    resources :people

    resources :conference do
      get "/schedule" => "schedule#show"
      put "/schedule" => "schedule#update"
      get "/registrations" => "registrations#show"
      get "/emailsettings" => "emails#show", :as => "email_settings"
      put "/emailsettings" => "emails#update", :as => "email_settings"
      get "/venue" => "venue#show", :as => "venue_info"
      put "/venue" => "venue#update", :as => "venue_update"
      get "/rooms" => "rooms#show", :as => "rooms_list"
      put "/rooms" => "rooms#update", :as => "rooms_update"
      get "/tracks" => "tracks#show", :as => "tracks_list"
      put "/tracks" => "tracks#update", :as => "tracks_update"
      get "/cfp" => "callforpapers#show", :as => "cfp_info"
      put "/cfp" => "callforpapers#update", :as => "cfp_update"
      post "/cfp" => "callforpapers#create", :as => "cfp_create"
      get "/event_types" => "eventtype#show", :as => "eventtype_list"
      put "/event_types" => "eventtype#update", :as => "eventtype_update"
      resources :events do
        member do
          post :comment
          put :update_state
          put :update_track
        end
      end
    end
  end

  resources :conference, :only => [] do
    resources :proposal do
      resources :event_attachment, :controller => "EventAttachments"
      put "/confirm" => "proposal#confirm"
    end
    member do
      get "/register" => "ConferenceRegistration#register"
      put "/register" => "ConferenceRegistration#update"
      delete "/register" => "ConferenceRegistration#unregister"
    end
  end
  match "/admin" => redirect("/admin/conference")

  root :to => "home#index"
end
