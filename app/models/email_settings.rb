class EmailSettings < ActiveRecord::Base
  attr_accessible :send_on_registration, :registration_subject, :registration_body,
                  :send_on_accepted, :accepted_subject, :accepted_body,
                  :send_on_rejected, :rejected_subject, :rejected_body,
                  :send_on_confirmed_without_registration, :confirmed_without_registration_subject, :confirmed_without_registration_body,
                  :send_on_conference_dates_updated, :conference_dates_updated_subject, :conference_dates_updated_body,
                  :send_on_conference_registration_dates_updated, :conference_registration_dates_updated_subject, :conference_registration_dates_updated_body,
                  :send_on_venue_updated, :venue_updated_subject, :venue_updated_body,
                  :send_on_call_for_papers_dates_updated, :call_for_papers_dates_updated_subject, :call_for_papers_dates_updated_body,
                  :send_on_call_for_papers_schedule_public, :call_for_papers_schedule_public_subject, :call_for_papers_schedule_public_body

  def get_values(conference, user, event = nil)
    h = {
      'email' => user.email,
      'name' => user.name,
      'conference' => conference.title,
      'conference_start_date' => conference.start_date,
      'conference_end_date' => conference.end_date,
      'registrationlink' => Rails.application.routes.url_helpers.conference_conference_registrations_url(
                            conference.short_title, host: CONFIG['url_for_emails']),
      'conference_splash_link' => Rails.application.routes.url_helpers.conference_url(
                                  conference.short_title, host: CONFIG['url_for_emails']),

      'schedule_link' => Rails.application.routes.url_helpers.schedule_conference_url(
                         conference.short_title, host: CONFIG['url_for_emails'])
    }

    if conference.call_for_paper
      h['cfp_start_date'] = conference.call_for_paper.start_date
      h['cfp_end_date'] = conference.call_for_paper.end_date
    else
      h['cfp_start_date'] = 'Unknown'
      h['cfp_end_date'] = 'Unknown'
    end

    if conference.venue
      h['venue'] = conference.venue.name
      h['venue_address'] = conference.venue.address
    else
      h['venue'] = 'Unknown'
      h['venue_address'] = 'Unknown'
    end

    if conference.registration_period
      h['registration_start_date'] = conference.registration_period.start_date
      h['registration_end_date'] = conference.registration_period.end_date
    end

    if event
      h['eventtitle'] = event.title
      h['proposalslink'] = Rails.application.routes.url_helpers.conference_proposal_index_url(
                           conference.short_title, host: CONFIG['url_for_emails'])
    end
    h
  end

  def generate_event_mail(event, event_template)
    values = get_values(event.conference, event.submitter, event)
    parse_template(event_template, values)
  end

  def generate_email_on_conf_updates(conference, user, conf_update_template)
    values = get_values(conference, user)
    parse_template(conf_update_template, values)
  end

  private

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
