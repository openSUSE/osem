# frozen_string_literal: true

# == Schema Information
#
# Table name: email_settings
#
#  id                                            :bigint           not null, primary key
#  accepted_body                                 :text
#  accepted_subject                              :string
#  booths_acceptance_body                        :text
#  booths_acceptance_subject                     :string
#  booths_rejection_body                         :text
#  booths_rejection_subject                      :string
#  cfp_dates_updated_body                        :text
#  cfp_dates_updated_subject                     :string
#  conference_dates_updated_body                 :text
#  conference_dates_updated_subject              :string
#  conference_registration_dates_updated_body    :text
#  conference_registration_dates_updated_subject :string
#  confirmed_without_registration_body           :text
#  confirmed_without_registration_subject        :string
#  program_schedule_public_body                  :text
#  program_schedule_public_subject               :string
#  registration_body                             :text
#  registration_subject                          :string
#  rejected_body                                 :text
#  rejected_subject                              :string
#  send_on_accepted                              :boolean          default(FALSE)
#  send_on_booths_acceptance                     :boolean          default(FALSE)
#  send_on_booths_rejection                      :boolean          default(FALSE)
#  send_on_cfp_dates_updated                     :boolean          default(FALSE)
#  send_on_conference_dates_updated              :boolean          default(FALSE)
#  send_on_conference_registration_dates_updated :boolean          default(FALSE)
#  send_on_confirmed_without_registration        :boolean          default(FALSE)
#  send_on_program_schedule_public               :boolean          default(FALSE)
#  send_on_registration                          :boolean          default(FALSE)
#  send_on_rejected                              :boolean          default(FALSE)
#  send_on_submitted_proposal                    :boolean          default(FALSE)
#  send_on_venue_updated                         :boolean          default(FALSE)
#  submitted_proposal_body                       :text
#  submitted_proposal_subject                    :string
#  venue_updated_body                            :text
#  venue_updated_subject                         :string
#  created_at                                    :datetime
#  updated_at                                    :datetime
#  conference_id                                 :integer
#
class EmailSettings < ApplicationRecord
  belongs_to :conference

  has_paper_trail on: [:update], ignore: [:updated_at], meta: { conference_id: :conference_id }

  def get_values(conference, user, event = nil, booth = nil)
    h = {
      'email'                  => user.email,
      'name'                   => user.name,
      'conference'             => conference.title,
      'conference_start_date'  => conference.start_date,
      'conference_end_date'    => conference.end_date,
      'registrationlink'       => Rails.application.routes.url_helpers.conference_conference_registration_url(
                            conference.short_title, host: (ENV['OSEM_HOSTNAME'] || 'localhost:3000')),
      'conference_splash_link' => Rails.application.routes.url_helpers.conference_url(
                                  conference.short_title, host: (ENV['OSEM_HOSTNAME'] || 'localhost:3000')),

      'schedule_link'          => Rails.application.routes.url_helpers.conference_schedule_url(
                         conference.short_title, host: (ENV['OSEM_HOSTNAME'] || 'localhost:3000'))
    }

    if conference.program.cfp
      h['cfp_start_date'] = conference.program.cfp.start_date
      h['cfp_end_date'] = conference.program.cfp.end_date
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
      h['proposalslink'] = Rails.application.routes.url_helpers.conference_program_proposals_url(
                           conference.short_title, host: (ENV['OSEM_HOSTNAME'] || 'localhost:3000'))
      h['committee_review'] = event.committee_review
      h['committee_review_html'] = ApplicationController.helpers.markdown(event.committee_review)
    end

    if booth
      h['booth_title'] = booth.title
    end
    h
  end

  def generate_event_mail(event, event_template)
    values = get_values(event.program.conference, event.submitter, event)
    parse_template(event_template, values)
  end

  def generate_email_on_conf_updates(conference, user, conf_update_template)
    values = get_values(conference, user)
    parse_template(conf_update_template, values)
  end

  def generate_booth_mail(booth, booth_template)
    values = get_values(booth.conference, booth.submitter, nil, booth)
    parse_template(booth_template, values)
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
