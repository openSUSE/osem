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
require 'spec_helper'

describe EmailSettings do
  let(:conference) { create(:conference, short_title: 'goto', start_date: Date.new(2014, 05, 01), end_date: Date.new(2014, 05, 06)) }
  let(:user) { create(:user, username: 'johnd', email: 'john@doe.com', name: 'John Doe') }
  let(:event) { create(:event, program: conference.program, title: 'Talk about talks', submitter: user) }
  let(:expected_hash) do
    {
      'email'                  => 'john@doe.com',
      'name'                   => 'John Doe',
      'conference'             => conference.title,
      'conference_start_date'  => Date.new(2014, 05, 01),
      'conference_end_date'    => Date.new(2014, 05, 06),
      'registrationlink'       => 'http://localhost:3000/conferences/goto/register',
      'conference_splash_link' => 'http://localhost:3000/conferences/goto',
      'schedule_link'          => 'http://localhost:3000/conferences/goto/schedule',
      'cfp_end_date'           => 'Unknown',
      'cfp_start_date'         => 'Unknown',
      'venue'                  => 'Unknown',
      'venue_address'          => 'Unknown'
    }
  end

  it 'has a valid factory' do
    expect(build(:email_settings)).to be_valid
  end

  describe '#get_values' do
    context 'user has name' do
      it 'returns correct key-value pairs' do
        expect(conference.email_settings.get_values(conference, user)).to eq expected_hash
      end
    end

    context 'user does not have name' do
      before do
        user.update_attributes(name: nil)
        username_hash = { 'name' => 'johnd' }
        expected_hash.merge!(username_hash)
      end

      it 'returns correct key-value pairs with username as name' do
        expect(conference.email_settings.get_values(conference, user)).to eq expected_hash
      end
    end

    context 'conference has cfp' do
      before do
        create(:cfp,
               start_date: Date.new(2014, 04, 29),
               end_date:   Date.new(2014, 05, 06),
               program:    conference.program)
        cfp_dates_hash = { 'cfp_start_date' => Date.new(2014, 04, 29), 'cfp_end_date' => Date.new(2014, 05, 06) }
        expected_hash.merge!(cfp_dates_hash)
      end

      it 'returns hash with cfp start and end date' do
        expect(conference.email_settings.get_values(conference, user)).to eq expected_hash
      end
    end

    context 'conference has venue' do
      before do
        conference.update_attributes(venue: create(:venue))
        venue_hash = { 'venue' => conference.venue.name, 'venue_address' => conference.venue.address }
        expected_hash.merge!(venue_hash)
      end

      it 'returns hash with venue and venue_address' do
        expect(conference.email_settings.get_values(conference, user)).to eq expected_hash
      end
    end

    context 'conference has registration period' do
      before do
        conference.update_attributes(registration_period: create(:registration_period,
                                                                 start_date: Date.new(2014, 05, 03),
                                                                 end_date:   Date.new(2014, 05, 05)))
        registration_period_hash = { 'registration_start_date' => Date.new(2014, 05, 03), 'registration_end_date' => Date.new(2014, 05, 05) }
        expected_hash.merge!(registration_period_hash)
      end

      it 'returns hash with registration_start_date and registration_end_date' do
        expect(conference.email_settings.get_values(conference, user)).to eq expected_hash
      end
    end

    context 'conference has event' do
      before do
        event_hash = {
          'eventtitle'            => 'Talk about talks',
          'proposalslink'         => 'http://localhost:3000/conferences/goto/program/proposals',
          'committee_review'      => nil,
          'committee_review_html' => ''
        }
        expected_hash.merge!(event_hash)
      end

      it 'returns hash with eventtitle and proposalslink' do
        expect(conference.email_settings.get_values(conference, user, event)).to eq expected_hash
      end
    end
  end

  describe '#generate_event_mail' do
    let(:event_template) do
      "Dear {name}\n\nWe are very pleased" \
      'to inform you that your submission {eventtitle} has been accepted for the conference {conference}.'
    end

    it 'replaces fillers in template' do
      expected_text = "Dear John Doe\n\nWe are very pleased" \
        "to inform you that your submission Talk about talks has been accepted for the conference #{conference.title}."
      expect(conference.email_settings.generate_event_mail(event, event_template)).to eq expected_text
    end
  end

  describe '#generate_email_on_conf_updates' do
    let(:conf_update_template) { "Dear {name},\n\nThank you for Registering for the conference {conference}." }

    it 'replaces fillers in template' do
      expected_text = "Dear John Doe,\n\nThank you for Registering for the conference #{conference.title}."
      expect(conference.email_settings.generate_email_on_conf_updates(conference, user, conf_update_template)).to eq expected_text
    end
  end
end
