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
      @step = params[:step] || 'filter'

      case @step
      when 'filter'
        @registrations = @conference.registrations.includes(:user, :qanswers)
        @questions = @conference.questions.includes(:qanswers)
      when 'recipients'
        @selected_recipients = filtered_recipients(params[:filter_type], params[:search_term])
        @filter_type = params[:filter_type]
        @search_term = params[:search_term]
      when 'compose'
        @recipient_emails = params[:recipient_emails] || []
        @filter_type = params[:filter_type]
        @search_term = params[:search_term]
      end
    end

    def recipients
      authorize! :index, @conference.email_settings

      recipients = filtered_recipients(params[:filter_type], params[:search_term])

      render json: {
        recipients: recipients.map do |user|
          {
            id:    user.id,
            name:  user.name,
            email: user.email
          }
        end,
        count:      recipients.count
      }
    end

    def send_bulk
      authorize! :index, @conference.email_settings

      subject = params[:subject]
      body = params[:body]
      recipient_emails = params[:recipient_emails] || []

      if subject.blank? || body.blank?
        redirect_to bulk_admin_conference_emails_path(@conference.short_title, step: 'compose'),
                    alert: 'Subject and body are required.'
        return
      end

      if recipient_emails.empty?
        redirect_to bulk_admin_conference_emails_path(@conference.short_title, step: 'recipients'),
                    alert: 'No recipients selected.'
        return
      end

      recipients = User.where(email: recipient_emails)

      recipients.each do |user|
        Mailbot.bulk_mail(@conference, user, subject, body).deliver_later
        Rails.logger.info "Bulk email queued - Subject: '#{subject}' - Recipient: #{user.email}"
      end

      redirect_to admin_conference_emails_path(@conference.short_title),
                  notice: "Bulk email sent to #{recipients.count} recipients."
    end

    private

    def filtered_recipients(filter_type, search_term = nil)
      base_users = get_base_user_set(filter_type)
      apply_search_filter(base_users, search_term)
    end

    def get_base_user_set(filter_type)
      registrations = @conference.registrations.includes(:user, :qanswers)

      case filter_type
      when 'no_questions_answered'
        users_with_no_answers(registrations)
      when 'some_questions_answered'
        users_with_some_answers(registrations)
      when 'all_questions_answered'
        users_with_all_answers(registrations)
      when 'all_registered'
        registrations.map(&:user)
      when 'not_registered'
        User.where.not(id: registrations.map(&:user_id))
      when 'all_users'
        User.all
      else
        []
      end
    end

    def users_with_no_answers(registrations)
      registrations.select { |r| r.qanswers.empty? }.map(&:user)
    end

    def users_with_some_answers(registrations)
      total_questions = @conference.questions.count
      registrations.select { |r| r.qanswers.any? && r.qanswers.count < total_questions }.map(&:user)
    end

    def users_with_all_answers(registrations)
      total_questions = @conference.questions.count
      registrations.select { |r| r.qanswers.count >= total_questions }.map(&:user)
    end

    def apply_search_filter(base_users, search_term)
      return base_users if search_term.blank?

      if base_users.respond_to?(:where)
        base_users.where('name ILIKE ? OR email ILIKE ?', "%#{search_term}%", "%#{search_term}%")
      else
        search_in_memory(base_users, search_term)
      end
    end

    def search_in_memory(users, search_term)
      lower_term = search_term.downcase
      users.select { |u| user_matches_search?(u, lower_term) }
    end

    def user_matches_search?(user, search_term)
      user.name&.downcase&.include?(search_term) || user.email&.downcase&.include?(search_term)
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
