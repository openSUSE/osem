# frozen_string_literal: true

module Admin
  class EmailsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource class: EmailSettings

    def update
      if @conference.email_settings.update(email_params)
        redirect_to admin_conference_emails_path(
                    @conference.short_title),
                    notice: 'Email settings have been successfully updated.'
      else
        redirect_to admin_conference_emails_path(
                    @conference.short_title),
                    error: "Updating email settings failed. #{@conference.email_settings.errors.to_a.join('. ')}."
      end
    end

    def index
      authorize! :index, @conference.email_settings
      @settings = @conference.email_settings
    end

    def custom_email
      subscriber_ids = @conference.subscriptions.pluck(:user_id)
      booths_responsible_ids = BoothRequest.where(booth_id: @conference.booth_ids).pluck(:user_id)
      confirmed_booth_ids = BoothRequest.where(booth_id: @conference.confirmed_booths.ids).pluck(:user_id)
      confirmed_track_ids = Track.find(@conference.confirmed_tracks.ids).pluck(:submitter_id)
      roles_ids = {}
      @conference.roles.each do |u|
        roles_ids[u.name] = u.users.pluck(:email)
      end
      @keys = {}
      @keys['Subscribers'] = User.find(subscriber_ids).pluck(:email) if subscriber_ids.present?
      @keys['Booths Responsible'] = User.find(booths_responsible_ids.uniq).pluck(:email) if booths_responsible_ids.present?
      @keys['Confirmed Booths'] = User.find(confirmed_booth_ids.uniq).pluck(:email) if confirmed_booth_ids.present?
      @keys['Registered Users'] = @conference.participants.pluck(:email) if @conference.participants.present?
      @keys['Confirmed Tracks'] = User.find(confirmed_track_ids.uniq).pluck(:email) if confirmed_track_ids.present?
      @keys['Supporters'] = @conference.supporters.pluck(:email) if @conference.supporters.present?
      @keys['Conference Organizers'] = roles_ids['organizer']
      @keys['Cfp'] = roles_ids['cfp'] if roles_ids['cfp'].present?
      @keys['Info Desk'] = roles_ids['info_desk'] if roles_ids['info_desk'].present?
      @keys['Volunteer Coordinator'] = roles_ids['volunteers_coordinator'] if roles_ids['volunteers_coordinator'].present?
    end

    private

    def email_params
      params.require(:email_settings).permit(:send_on_registration,
                                             :send_on_accepted, :send_on_rejected, :send_on_confirmed_without_registration,
                                             :send_on_submitted_proposal,
                                             :submitted_proposal_subject, :submitted_proposal_body,
                                             :registration_subject, :accepted_subject, :rejected_subject, :confirmed_without_registration_subject,
                                             :registration_body, :accepted_body, :rejected_body, :confirmed_without_registration_body,
                                             :send_on_conference_dates_updated, :conference_dates_updated_subject, :conference_dates_updated_body,
                                             :send_on_conference_registration_dates_updated, :conference_registration_dates_updated_subject, :conference_registration_dates_updated_body,
                                             :send_on_venue_updated, :venue_updated_subject, :venue_updated_body,
                                             :send_on_cfp_dates_updated, :cfp_dates_updated_subject, :cfp_dates_updated_body,
                                             :send_on_program_schedule_public, :program_schedule_public_subject, :program_schedule_public_body,
                                             :send_on_booths_acceptance, :booths_acceptance_subject, :booths_acceptance_body,
                                             :send_on_booths_rejection, :booths_rejection_subject, :booths_rejection_body)
    end
  end
end
