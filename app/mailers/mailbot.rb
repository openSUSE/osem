class Mailbot < ActionMailer::Base
  default from: "no-reply@example.com"

  def registration_mail(conference, person)
    build_email(conference,
                person.email,
                conference.email_settings.registration_subject,
                conference.email_settings.generate_registration_email(conference, person))

  end

  def acceptance_mail(event)
    conference = event.conference
    person = event.submitter
    build_email(conference,
                person.email,
                conference.email_settings.accepted_subject,
                conference.email_settings.generate_accepted_email(event))

  end

  def rejection_mail(event)
    conference = event.conference
    person = event.submitter
    build_email(conference,
                person.email,
                conference.email_settings.rejected_subject,
                conference.email_settings.generate_rejected_email(event))
  end

  def confirm_reminder_mail(event)
    conference = event.conference
    person = event.submitter

    build_email(conference,
                person.email,
                conference.email_settings.confirmed_without_registration_subject,
                conference.email_settings.confirmed_but_not_registered_email(event))
  end

  def conference_date_update_mail(conference,dates)
    subject = conference.email_settings.updated_conference_dates_subject.blank? ? "#{conference.title} dates updated" : conference.email_settings.updated_conference_dates_subject
    partial = "#{conference.title}\n New Dates : #{dates}\n For more information visit #{Rails.application.routes.url_helpers.conference_path(conference.short_title,  host: CONFIG['url_for_emails'])}"
    body = conference.email_settings.updated_conference_dates_template.blank? ? "#{partial}" : "#{conference.email_settings.updated_conference_dates_template}\n #{partial}"
    conference.registrations.each do |u|
      build_email(conference, u.user.email, subject, body)
    end
  end

  def build_email(conference, to, subject, body)
    mail(:to => to,
         :from => conference.contact_email,
         :reply_to => conference.contact_email,
         :subject => subject,
         :body => body)
  end

end
