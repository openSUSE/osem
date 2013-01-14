class Mailbot < ActionMailer::Base
  default from: "no-reply@example.com"

  def registration_mail(host, conference, person)
    mail(:to => person.email,
         :from => conference.contact_email,
         :reply_to => conference.contact_email,
         :subject => conference.email_settings.registration_subject,
         :body => conference.email_settings.generate_registration_email(host, conference, person))
  end

  def acceptance_mail(host, conference, person, event)
    mail(:to => person.email,
         :from => conference.contact_email,
         :reply_to => conference.contact_email,
         :subject => conference.email_settings.accepted_subject,
         :body => conference.email_settings.generate_accepted_email(host, conference, person, event))
  end

  def rejection_mail(host, conference, person, event)
    mail(:to => person.email,
         :from => conference.contact_email,
         :reply_to => conference.contact_email,
         :subject => conference.email_settings.rejected_subject,
         :body => conference.email_settings.generate_rejected_email(host, conference, person, event))
  end

  def confirm_reminder_mail(host, conference, person, event)
    mail(:to => person.email,
         :from => conference.contact_email,
         :reply_to => conference.contact_email,
         :subject => conference.email_settings.confirmed_without_registration_subject,
         :body => conference.email_settings.confirmed_but_not_registered_email(host, conference, person, event))
  end

end
