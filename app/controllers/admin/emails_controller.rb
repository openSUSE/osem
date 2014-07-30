module Admin
  class EmailsController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :emails, class: EmailSettings

    def update
      @conference.email_settings.update_attributes(params[:email_settings])
      redirect_to(admin_conference_emails_path(
                  @conference.short_title),
                  notice: 'Settings have been successfully updated.')
    end

    def index
      @settings = @conference.email_settings
    end
  end
end
