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

  def build_email(conference, to, subject, body)
    mail(:to => to,
         :from => conference.contact_email,
         :reply_to => conference.contact_email,
         :subject => subject,
         :body => body)
  end

end
