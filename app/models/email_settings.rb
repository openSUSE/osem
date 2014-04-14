class EmailSettings < ActiveRecord::Base
  attr_accessible :send_on_registration, :send_on_accepted, :send_on_rejected, :send_on_confirmed_without_registration,
                  :registration_email_template, :accepted_email_template, :rejected_email_template, :confirmed_email_template,
                  :registration_subject, :accepted_subject, :rejected_subject, :confirmed_without_registration_subject

  def get_values(conference, person, event = nil)
    h = {
        "email" => person.email,
        "name" => person.public_name,
        "conference" => conference.title,
        "registrationlink" => Rails.application.routes.url_helpers.register_conference_url(conference.short_title, :host => CONFIG["url_for_emails"])
    }

    if !event.nil?
      h["eventtitle"] = event.title
      h["proposalslink"] = Rails.application.routes.url_helpers.conference_proposal_url(conference.short_title, event, :host => CONFIG["url_for_emails"])
    end
    h
  end

  def generate_registration_email(conference, person)
    values = get_values(conference, person)
    template = self.registration_email_template
    parse_template(template, values)
  end


  def generate_accepted_email(event)
    values = get_values(event.conference, event.submitter, event)
    template = self.accepted_email_template
    parse_template(template, values)
  end

  def generate_rejected_email(event)
    values = get_values(event.conference, event.submitter, event)
    template = self.rejected_email_template
    parse_template(template, values)
  end

  def confirmed_but_not_registered_email(event)
    values = get_values(event.conference, event.submitter, event)
    template = self.confirmed_email_template
    parse_template(template, values)
  end

  def parse_template(text, values)
    values.each do |key, value|
      text = text.gsub"{#{key}}", value unless text.blank?
    end
    text
  end
end
