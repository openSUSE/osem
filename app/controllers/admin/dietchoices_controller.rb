module Admin
  class DietchoicesController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :dietary_choice, through: :conference

    def show
      render :diets_list
    end

    def update
      begin
        @conference.update_attributes!(params[:conference])
        redirect_to(admin_conference_dietary_list_path(:conference_id => @conference.short_title), :notice => 'Dietary choices were successfully updated.')
      rescue => e
        redirect_to(admin_conference_dietary_list_path(:conference_id => @conference.short_title), :alert => "Dietary choices update failed: #{e.message}")
      end
    end
  end
end
