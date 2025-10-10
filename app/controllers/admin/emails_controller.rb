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

    def bulk
      authorize! :index, @conference.email_settings
      @registrations = @conference.registrations.includes(:user, :qanswers)
      @questions = @conference.questions.includes(:qanswers)
    end

    def send_bulk
      authorize! :index, @conference.email_settings

      subject = params[:subject]
      body = params[:body]
      filter_type = params[:filter_type]

      if subject.blank? || body.blank?
        redirect_to bulk_admin_conference_emails_path(@conference.short_title), alert: 'Subject and body are required.'
        return
      end

      recipients = get_filtered_recipients(filter_type)

      if recipients.empty?
        redirect_to bulk_admin_conference_emails_path(@conference.short_title), alert: 'No recipients found with the selected filter.'
        return
      end

      recipients.each do |user|
        Mailbot.bulk_mail(@conference, user, subject, body).deliver_later
      end

      redirect_to bulk_admin_conference_emails_path(@conference.short_title),
                  notice: "Bulk email sent to #{recipients.count} recipients."
    end

    private

    def get_filtered_recipients(filter_type)
      registrations = @conference.registrations.includes(:user, :qanswers)

      case filter_type
      when 'no_questions_answered'
        registrations.select { |r| r.qanswers.empty? }.map(&:user)
      when 'some_questions_answered'
        registrations.select { |r| r.qanswers.any? && r.qanswers.count < @conference.questions.count }.map(&:user)
      when 'all_questions_answered'
        registrations.select { |r| r.qanswers.count >= @conference.questions.count }.map(&:user)
      when 'all_registered'
        registrations.map(&:user)
      else
        []
      end
    end

    def bulk_email_params
      params.permit(:subject, :body, :filter_type)
    end

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
