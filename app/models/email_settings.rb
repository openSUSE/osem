class EmailSettings < ActiveRecord::Base
  attr_accessible :send_on_registration, :send_on_accepted, :send_on_rejected, :send_on_confirmed_without_registration,
                  :registration_email_template, :accepted_email_template, :rejected_email_template, :confirmed_email_template,
                  :registration_subject, :accepted_subject, :rejected_subject, :confirmed_without_registration_subject

  def get_values(host, conference, person, event)
    h = {
        "email" => person.email,
        "name" => person.public_name,
        "conference" => conference.title,
        "proposalslink" => Rails.application.routes.url_helpers.conference_proposal_index_url(conference.short_title, :host => host),
        "registrationlink" => Rails.application.routes.url_helpers.register_conference_url(conference.short_title, :host => host)
    }

    if !event.nil?
      h["eventtitle"] = event.title
    end
    h
  end

  def generate_registration_email(host, conference, person)
    values = get_values(host, conference, person, nil)
    template = self.registration_email_template
    parse_template(template, values)
  end


  def generate_accepted_email(host, conference, person, event)
    values = get_values(host, conference, person, event)
    template = self.accepted_email_template
    parse_template(template, values)
  end

  def generate_rejected_email(host, conference, person, event)
    values = get_values(host, conference, person, event)
    template = self.rejected_email_template
    parse_template(template, values)
  end

  def confirmed_but_not_registered_email(host, conference, person, event)
    values = get_values(host, conference, person, event)
    template = self.confirmed_email_template
    parse_template(template, values)
  end

  def parse_template(text, values)
    values.each do |key, value|
      text = text.sub"{#{key}}", value
    end
    text
  end
end