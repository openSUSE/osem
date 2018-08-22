# frozen_string_literal: true

class Mailbot < ActionMailer::Base
  def registration_mail(conference, user)
    mail(to: user.email,
         from: conference.contact.email,
         subject: conference.email_settings.registration_subject,
         body: conference.email_settings.generate_email_on_conf_updates(conference,
                                                                        user,
                                                                        conference.email_settings.registration_body))
  end

  def ticket_confirmation_mail(ticket_purchase)
    @ticket_purchase = ticket_purchase
    @conference = ticket_purchase.conference
    @user = ticket_purchase.user

    PhysicalTicket.last(ticket_purchase.quantity).each do |physical_ticket|
      pdf = TicketPdf.new(@conference, @user, physical_ticket, @conference.ticket_layout.to_sym, "ticket_for_#{@conference.short_title}_#{physical_ticket.id}")
      attachments["ticket_for_#{@conference.short_title}_#{physical_ticket.id}.pdf"] = pdf.render
    end

    mail(to: @user.email,
         from: @conference.contact.email,
         template_name: 'ticket_confirmation_template',
         subject: "#{@conference.title} | Ticket Confirmation and PDF!")
  end

  def acceptance_mail(event)
    conference = event.program.conference

    mail(to: event.submitter.email,
         from: conference.contact.email,
         subject: conference.email_settings.accepted_subject,
         body: conference.email_settings.generate_event_mail(event, conference.email_settings.accepted_body))
  end

  def submitted_proposal_mail(event)
    conference = event.program.conference

    mail(to: event.submitter.email,
         from: conference.contact.email,
         subject: conference.email_settings.submitted_proposal_subject,
         body: conference.email_settings.generate_event_mail(event, conference.email_settings.submitted_proposal_body))
  end

  def rejection_mail(event)
    conference = event.program.conference

    mail(to: event.submitter.email,
         from: conference.contact.email,
         subject: conference.email_settings.rejected_subject,
         body: conference.email_settings.generate_event_mail(event, conference.email_settings.rejected_body))
  end

  def confirm_reminder_mail(event)
    conference = event.program.conference

    mail(to: event.submitter.email,
         from: conference.contact.email,
         subject: conference.email_settings.confirmed_without_registration_subject,
         body: conference.email_settings.generate_event_mail(event,
                                                             conference.email_settings.confirmed_without_registration_body))
  end

  def conference_date_update_mail(conference, user)
    mail(to: user.email,
         from: conference.contact.email,
         subject: conference.email_settings.conference_dates_updated_subject,
         body: conference.email_settings.generate_email_on_conf_updates(conference,
                                                                        user,
                                                                        conference.email_settings.conference_dates_updated_body))
  end

  def conference_registration_date_update_mail(conference, user)
    mail(to: user.email,
         from: conference.contact.email,
         subject: conference.email_settings.conference_registration_dates_updated_subject,
         body: conference.email_settings.generate_email_on_conf_updates(conference,
                                                                        user,
                                                                        conference.email_settings.conference_registration_dates_updated_body))
  end

  def conference_venue_update_mail(conference, user)
    mail(to: user.email,
         from: conference.contact.email,
         subject: conference.email_settings.venue_updated_subject,
         body: conference.email_settings.generate_email_on_conf_updates(conference,
                                                                        user,
                                                                        conference.email_settings.venue_updated_body))
  end

  def conference_schedule_update_mail(conference, user)
    mail(to: user.email,
         from: conference.contact.email,
         subject: conference.email_settings.program_schedule_public_subject,
         body: conference.email_settings.generate_email_on_conf_updates(conference,
                                                                        user,
                                                                        conference.email_settings.program_schedule_public_body))
  end

  def conference_cfp_update_mail(conference, user)
    mail(to: user.email,
         from: conference.contact.email,
         subject: conference.email_settings.cfp_dates_updated_subject,
         body: conference.email_settings.generate_email_on_conf_updates(conference,
                                                                        user,
                                                                        conference.email_settings.cfp_dates_updated_body))
  end

  def conference_booths_acceptance_mail(booth)
    conference = booth.conference

    mail(to: booth.submitter.email,
         from: conference.contact.email,
         subject: conference.email_settings.booths_acceptance_subject,
         body: conference.email_settings.generate_booth_mail(booth, conference.email_settings.booths_acceptance_body))
  end

  def conference_booths_rejection_mail(booth)
    conference = booth.conference

    mail(to: booth.submitter.email,
         from: conference.contact.email,
         subject: conference.email_settings.booths_rejection_subject,
         body: conference.email_settings.generate_booth_mail(booth, conference.email_settings.booths_rejection_body))
  end

  def event_comment_mail(comment, user)
    @comment = comment
    @event = @comment.commentable
    @conference = @event.program.conference
    @user = user

    mail(to: @user.email,
         from: @conference.contact.email,
         template_name: 'comment_template',
         subject: "New comment has been posted for #{@event.title}")
  end
end
