class EmailSettings < ActiveRecord::Base
  attr_accessible :send_on_registration, :send_on_accepted, :send_on_rejected,
                  :send_on_confirmed_without_registration, :registration_email_template,
                  :accepted_email_template, :rejected_email_template, :confirmed_email_template,
                  :registration_subject, :accepted_subject, :rejected_subject,
                  :confirmed_without_registration_subject,
                  :send_on_updated_conference_dates, :updated_conference_dates_subject,
                  :updated_conference_dates_template, :send_on_updated_conference_registration_dates,
                  :updated_conference_registration_dates_subject, :updated_conference_registration_dates_template,
                  :send_on_venue_update, :venue_update_subject, :venue_update_template

  def get_values(conference, user, event = nil)
    h = {
      'email' => user.email,
      'name' => user.name,
      'conference' => conference.title,
      'conference_start_date' => conference.start_date,
      'conference_end_date' => conference.end_date,
      'registration_start_date' => conference.registration_start_date,
      'registration_end_date' => conference.registration_end_date,
      'venue' => conference.venue.name,
      'venue_address' => conference.venue.address,
      'registrationlink' => Rails.application.routes.url_helpers.register_conference_url(
                            conference.short_title, host: CONFIG['url_for_emails']),
      'conference_splash_link' => Rails.application.routes.url_helpers.conference_url(
                                  conference.short_title, host: CONFIG['url_for_emails']),
      'cfp_start_date' => conference.call_for_papers.start_date,
      'cfp_end_date' => conference.call_for_papers.end_date,
      'schedule_link' => Rails.application.routes.url_helpers.conference_schedule_url(
                         conference.short_title, host: CONFIG['url_for_emails'])
    }

    if !event.nil?
      h['eventtitle'] = event.title
      h['proposalslink'] = Rails.application.routes.url_helpers.conference_proposal_url(
                           conference.short_title, event, host: CONFIG['url_for_emails'])
    end
    h
  end

  def generate_registration_email(conference, user)
    values = get_values(conference, user)
    template = registration_email_template
    parse_template(template, values)
  end

  def generate_accepted_email(event)
    values = get_values(event.conference, event.submitter, event)
    template = accepted_email_template
    parse_template(template, values)
  end

  def generate_rejected_email(event)
    values = get_values(event.conference, event.submitter, event)
    template = rejected_email_template
    parse_template(template, values)
  end

  def confirmed_but_not_registered_email(event)
    values = get_values(event.conference, event.submitter, event)
    template = confirmed_email_template
    parse_template(template, values)
  end

  def generate_conference_date_update_mail(conference, user)
    values = get_values(conference, user)
    template = updated_conference_dates_template
    parse_template(template, values)
  end

  def generate_conference_registration_date_update_mail(conference, user)
    values = get_values(conference, user)
    template = updated_conference_registration_dates_template
    parse_template(template, values)
  end

  def generate_send_email_on_venue_update(conference, user)
    values = get_values(conference, user)
    template = venue_update_template
    parse_template(template, values)
  end

  def parse_template(text, values)
    values.each do |key, value|
      if value.kind_of?(Date)
        text = text.gsub "{#{key}}", value.strftime('%Y-%m-%d') unless text.blank?
      else
        text = text.gsub "{#{key}}", value unless text.blank? || value.blank?
      end
    end
    text
  end
end
