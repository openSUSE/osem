class EmailSettings < ActiveRecord::Base
  attr_accessible :send_on_registration, :send_on_accepted, :send_on_rejected, :send_on_confirmed_without_registration,
                  :registration_email_template, :accepted_email_template, :rejected_email_template, :confirmed_email_template,
                  :registration_subject, :accepted_subject, :rejected_subject, :confirmed_without_registration_subject

  before_save :set_default

  def set_default
    self.registration_subject = "Your Registration for {conference}" unless self.registration_subject
    self.registration_email_template = "Dear {name},\n\n" +
        "Thank you for Registering for the conference {conference}.\n\n" +
        "Please complete your registration by filling out your travel information. If you are unable to attend please unregister online.\n" +
        "{registrationlink}\n\n" +
        "Feel free to contact us with any questions or concerns.\n\n" +
        "We look forward to seeing you there.\n\n" +
        "Best wishes\n\nOSEM Team" unless self.registration_email_template

    self.accepted_subject = "Your submission {eventtitle} has been accepted" unless self.accepted_subject
    self.accepted_email_template = "Dear {name},\n\n" +
        "We are very pleased to inform you that your submission {eventtitle} has been accepted for the conference {conference}.\n\n" +
        "The public page of your submission can be found at:\n" +
        "{proposalslink}\n\n" +
        "If you havent already registered for {conference}, please do as soon as possible:\n" +
        "{registrationlink}\n\n" +
        "Feel free to contact us with any questions or concerns.\n\n" +
        "We look forward to seeing you there.\n\n" +
        "Best wishes\n\nOSEM Team" unless self.accepted_email_template

    self.rejected_subject = "Your submission {eventtitle} has been rejected" unless self.rejected_subject
    self.rejected_email_template = "Dear {name},\n\n" +
        "Thank you for your submission {eventtitle} for the conference {conference}." +
        "After careful consideration we are sorry to inform you that your submission has been rejected.\n\n" +
        "Best wishes\n\nOSEM Team" unless self.rejected_email_template

    self.confirmed_without_registration_subject = "Your submission {eventtitle} has been confirmed" unless self.confirmed_without_registration_subject
    self.confirmed_email_template = "Dear {name},\n\n" +
        "Thank you for the confirmation of {eventtitle}. " +
        "Unfortunately you are not registered for the conference {conference}. " +
        "Please register as soon as possible:" +
        "{registrationlink}\n\n" +
        "Feel free to contact us with any questions or concerns.\n\n" +
        "We look forward to seeing you there.\n\n" +
        "Best wishes\n\nOSEM Team" unless self.confirmed_email_template
  end

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
      text = text.gsub"{#{key}}", value
    end
    text
  end
end
