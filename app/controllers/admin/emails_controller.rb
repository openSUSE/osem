module Admin
  class EmailsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource class: EmailSettings

    def update
      @conference.email_settings.update_attributes(params[:email_settings])

      flash[:notice] = 'Settings have been successfully updated.'
      redirect_to admin_conference_emails_path(@conference.short_title)
    end

    def index
      authorize! :index, @conference.email_settings
      @settings = @conference.email_settings
    end
  end
end
