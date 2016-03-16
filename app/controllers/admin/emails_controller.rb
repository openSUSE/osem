module Admin
  class EmailsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource class: EmailSettings

    def update
      @conference.email_settings.update_attributes(email_params)
      redirect_to admin_conference_emails_path(
                  @conference.short_title),
                  notice: 'Settings have been successfully updated.'
    end

    def index
      authorize! :index, @conference.email_settings
      @settings = @conference.email_settings
    end

    private

    def email_params
      params.require(:email_settings).permit(:send_on_registration, :send_on_accepted, :send_on_rejected, :send_on_confirmed_without_registration,
                                             :registration_subject, :accepted_subject, :rejected_subject, :confirmed_without_registration_subject,
                                             :registration_body, :accepted_body, :rejected_body, :confirmed_without_registration_body,
                                             :send_on_conference_dates_updated, :conference_dates_updated_subject, :conference_dates_updated_body,
                                             :send_on_conference_registration_dates_updated, :conference_registration_dates_updated_subject, :conference_registration_dates_updated_body,
                                             :send_on_venue_updated, :venue_updated_subject, :venue_updated_body,
                                             :send_on_call_for_papers_dates_updated, :call_for_papers_dates_updated_subject, :call_for_papers_dates_updated_body,
                                             :send_on_call_for_papers_schedule_public, :call_for_papers_schedule_public_subject, :call_for_papers_schedule_public_body)
    end
  end
end
