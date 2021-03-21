# frozen_string_literal: true

SNAPCON_BCC_ADDRESS = 'messages@snap.berkeley.edu'
EMAIL_TEMPLATE = 'email_template'
YTLF_TICKET_ID = 50

class Mailbot < ActionMailer::Base
  helper ConferenceHelper

  default bcc:           -> { SNAPCON_BCC_ADDRESS },
          template_name: -> { EMAIL_TEMPLATE },
          to:            -> { @user.email },
          from:          -> { @conference.contact.email }

  def registration_mail(conference, user)
    @user = user
    @conference = conference
    @email_body = @conference.email_settings.generate_email_on_conf_updates(@conference, @user, @conference.email_settings.registration_body)

    mail(subject: @conference.email_settings.registration_subject)
  end

  def ticket_confirmation_mail(ticket_purchase)
    @ticket_purchase = ticket_purchase
    @user = ticket_purchase.user
    @conference = ticket_purchase.conference

    PhysicalTicket.last(ticket_purchase.quantity).each do |physical_ticket|
      pdf = TicketPdf.new(@conference, @user, physical_ticket, @conference.ticket_layout.to_sym, "ticket_for_#{@conference.short_title}_#{physical_ticket.id}")
      attachments["ticket_for_#{@conference.short_title}_#{physical_ticket.id}.pdf"] = pdf.render
    end

    template_name = 'ticket_confirmation_template'
    if @ticket_purchase.ticket_id == YTLF_TICKET_ID
      template_name = 'young_thinkers_ticket_confirmation_template'
    end

    mail(subject:       "#{@conference.title} | Ticket Confirmation and PDF!",
         template_name: template_name)
  end

  def acceptance_mail(event)
    @user = event.submitter
    @conference = event.program.conference
    @email_body = @conference.email_settings.generate_event_mail(event, @conference.email_settings.accepted_body)

    mail(subject: @conference.email_settings.accepted_subject)
  end

  def submitted_proposal_mail(event)
    @user = event.submitter
    @conference = event.program.conference
    @email_body = @conference.email_settings.generate_event_mail(event, @conference.email_settings.submitted_proposal_body)

    mail(subject: @conference.email_settings.submitted_proposal_subject)
  end

  def rejection_mail(event)
    @user = event.submitter
    @conference = event.program.conference
    @email_body = @conference.email_settings.generate_event_mail(event, @conference.email_settings.rejected_body)

    mail(subject: @conference.email_settings.rejected_subject)
  end

  def confirm_reminder_mail(event)
    @user = event.submitter
    @conference = event.program.conference
    @email_body = @conference.email_settings.generate_event_mail(event, @conference.email_settings.confirmed_without_registration_body)

    mail(subject: @conference.email_settings.confirmed_without_registration_subject)
  end

  def conference_date_update_mail(conference, user)
    @user = user
    @conference = conference
    @email_body = @conference.email_settings.generate_email_on_conf_updates(@conference, @user, @conference.email_settings.conference_dates_updated_body)

    mail(subject: @conference.email_settings.conference_dates_updated_subject)
  end

  def conference_registration_date_update_mail(conference, user)
    @user = user
    @conference = conference
    @email_body = @conference.email_settings.generate_email_on_conf_updates(@conference, @user, @conference.email_settings.conference_registration_dates_updated_body)

    mail(subject: @conference.email_settings.conference_registration_dates_updated_subject)
  end

  def conference_venue_update_mail(conference, user)
    @user = user
    @conference = conference
    @email_body = @conference.email_settings.generate_email_on_conf_updates(@conference, @user, @conference.email_settings.venue_updated_body)

    mail(subject: @conference.email_settings.venue_updated_subject)
  end

  def conference_schedule_update_mail(conference, user)
    @user = user
    @conference = conference
    @email_body = @conference.email_settings.generate_email_on_conf_updates(@conference, @user, @conference.email_settings.program_schedule_public_body)

    mail(bcc:     nil,
         subject: @conference.email_settings.program_schedule_public_subject)
  end

  def conference_cfp_update_mail(conference, user)
    @user = user
    @conference = conference
    @email_body = @conference.email_settings.generate_email_on_conf_updates(@conference, @user, @conference.email_settings.cfp_dates_updated_body)

    mail(bcc:     nil,
         subject: @conference.email_settings.cfp_dates_updated_subject)
  end

  def conference_booths_acceptance_mail(booth)
    @user = booth.submitter
    @conference = booth.conference
    @email_body = @conference.email_settings.generate_booth_mail(booth, @conference.email_settings.booths_acceptance_body)

    mail(bcc:     nil,
         subject: @conference.email_settings.booths_acceptance_subject)
  end

  def conference_booths_rejection_mail(booth)
    @user = booth.submitter
    @conference = booth.conference
    @email_body = @conference.email_settings.generate_booth_mail(booth, @conference.email_settings.booths_rejection_body)

    mail(bcc:     nil,
         subject: @conference.email_settings.booths_rejection_subject)
  end

  def event_comment_mail(comment, user)
    @comment = comment
    @event = @comment.commentable
    @conference = @event.program.conference
    @user = user

    mail(bcc:           nil,
         template_name: 'comment_template',
         subject:       "New comment has been posted for #{@event.title}")
  end
end
