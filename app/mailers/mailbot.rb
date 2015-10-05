class Mailbot < ActionMailer::Base
  default from: 'no-reply@example.com'

  def registration_mail(conference, person)
    build_email(conference,
                person.email,
                conference.email_settings.registration_subject,
                conference.email_settings.generate_email_on_conf_updates(conference, person, conference.email_settings.registration_email_template))
  end

  def acceptance_mail(event)
    conference = event.conference
    person = event.submitter
    build_email(conference,
                person.email,
                conference.email_settings.accepted_subject,
                conference.email_settings.generate_event_mail(event, conference.email_settings.accepted_email_template))
  end

  def rejection_mail(event)
    conference = event.conference
    person = event.submitter
    build_email(conference,
                person.email,
                conference.email_settings.rejected_subject,
                conference.email_settings.generate_event_mail(event, conference.email_settings.rejected_email_template))
  end

  def confirm_reminder_mail(event)
    conference = event.conference
    person = event.submitter
    build_email(conference,
                person.email,
                conference.email_settings.confirmed_without_registration_subject,
                conference.email_settings.generate_event_mail(event, conference.email_settings.confirmed_email_template))
  end

  def conference_date_update_mail(conference)
    User.joins(:subscriptions).merge(conference.subscriptions) do |user|
      build_email(conference,
                  user.email,
                  conference.email_settings.updated_conference_dates_subject,
                  conference.email_settings.generate_email_on_conf_updates(conference, user, conference.email_settings.updated_conference_dates_template))
    end
  end

  def conference_registration_date_update_mail(conference)
    User.joins(:subscriptions).merge(conference.subscriptions).uniq.joins('INNER JOIN registrations ON registrations.user_id != users.id').merge(conference.registrations) do |user|
      build_email(conference,
                  user.email,
                  conference.email_settings.updated_conference_registration_dates_subject,
                  conference.email_settings.generate_email_on_conf_updates(conference, user, conference.email_settings.updated_conference_registration_dates_template))
    end
  end

  def send_email_on_venue_update(conference)
    User.joins(:subscriptions).merge(conference.subscriptions) do |user|
      build_email(conference,
                  user.email,
                  conference.email_settings.venue_update_subject,
                  conference.email_settings.generate_email_on_conf_updates(conference, user, conference.email_settings.venue_update_template))
    end
  end

  def send_on_schedule_public(conference)
    User.joins(:subscriptions).merge(conference.subscriptions) do |user|
      build_email(conference,
                  user.email,
                  conference.email_settings.call_for_papers_schedule_public_subject,
                  conference.email_settings.generate_email_on_conf_updates(conference, user, conference.email_settings.call_for_papers_schedule_public_template))
    end
  end

  def send_on_call_for_papers_dates_updates(conference)
    User.joins(:subscriptions).merge(conference.subscriptions) do |user|
      build_email(conference,
                  user.email,
                  conference.email_settings.call_for_papers_dates_updates_subject,
                  conference.email_settings.generate_email_on_conf_updates(conference, user, conference.email_settings.call_for_papers_dates_updates_template))
    end
  end

  def send_notification_email_for_comment(comment)
    @comment = comment
    @event = @comment.commentable
    @conference = @event.conference
    recipients = User.comment_notifiable(@conference) # with scope
    recipients.each do |user|
      @user = user
      mail(to: @user.email,
           from: @conference.contact.email,
           reply_to: @conference.contact.email,
           template_path: 'admin/emails',
           template_name: 'comment_template',
           subject: "New comment has been posted for #{@event.title}")
    end
  end

  def build_email(conference, to, subject, body)
    mail(to: to,
         from: conference.contact.email,
         reply_to: conference.contact.email,
         subject: subject,
         body: body)
  end
end
