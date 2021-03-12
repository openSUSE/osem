# frozen_string_literal: true

require 'spec_helper'

describe ConferenceHelper, type: :helper do
  let!(:conference) { create(:conference) }
  let!(:contact) { create(:contact, conference: conference) }

  describe '#one_call_open' do
    it 'is falsey if neither call is open' do
      expect(one_call_open(*conference.program.cfps)).to be_falsey
    end

    it 'is truthy if call_for_papers is open' do
      create(
        :cfp,
        program:    conference.program,
        cfp_type:   'events',
        start_date: conference.start_date,
        end_date:   conference.end_date
      )
      expect(one_call_open(*conference.program.cfps)).to be_truthy
    end

    it 'is truthy if call_for_tracks is open' do
      create(
        :cfp,
        program:    conference.program,
        cfp_type:   'tracks',
        start_date: conference.start_date,
        end_date:   conference.end_date
      )

      expect(one_call_open(*conference.program.cfps)).to be_truthy
    end

    it 'is falsey if both calls are open' do
      create(
        :cfp,
        program:    conference.program,
        cfp_type:   'events',
        start_date: conference.start_date,
        end_date:   conference.end_date
      )
      create(
        :cfp,
        program:    conference.program,
        cfp_type:   'tracks',
        start_date: conference.start_date,
        end_date:   conference.end_date
      )

      expect(one_call_open(*conference.program.cfps)).to be_falsey
    end
  end

  describe '#sponsorship_mailto' do
    it 'constructs a mailto URL' do
      expect(sponsorship_mailto(conference)).to match 'mailto:'
    end

    it 'points to the conference sponsor address' do
      expect(sponsorship_mailto(conference)).to match contact.sponsor_email
    end

    it 'includes a conference identifier' do
      expect(sponsorship_mailto(conference)).to match conference.short_title
    end
  end

  describe '#conference_logo_url' do
    let(:organization) { create(:organization) }
    let(:conference2) { create(:conference, organization: organization) }

    it 'gives the correct logo url' do
      mailbot = Mailbot.new
      expect(conference_logo_url(conference2)).to eq('snapcon_logo.png')

      File.open('spec/support/logos/1.png') do |file|
        organization.picture = file
      end

      expect(conference_logo_url(conference2)).to include('1.png')

      File.open('spec/support/logos/2.png') do |file|
        conference2.picture = file
      end

      expect(conference_logo_url(conference2)).to include('2.png')
    end
  end
end
