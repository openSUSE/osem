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

  describe '#conference_color' do
    let(:conference2) { create(:conference, color: '#000000') }

    it 'gives the correct conference color' do
      expect(conference_color(conference2)).to eq('#000000')

      conference2.color = ''
      expect(conference_color(conference2)).to eq('#0B3559')
    end
  end

  describe '#get_happening_next_events_schedules' do
    let!(:conference2) { create(:full_conference, start_date: 1.day.ago, end_date: 7.days.from_now, start_hour: 0, end_hour: 24) }
    let!(:program) { conference2.program }
    let!(:selected_schedule) { create(:schedule, program: program) }
    let!(:scheduled_event1) do
      program.update_attributes!(selected_schedule: selected_schedule)
      create(:event, program: program, state: 'confirmed', abstract: '`markdown`')
    end
    let!(:current_time) { Time.now.in_time_zone(conference2.timezone) }
    let!(:event_schedule1) { create(:event_schedule, event: scheduled_event1, schedule: selected_schedule, start_time: (current_time + 1.hour).strftime('%a, %d %b %Y %H:%M:%S')) }
    let!(:scheduled_event2) do
      program.update_attributes!(selected_schedule: selected_schedule)
      create(:event, program: program, state: 'confirmed')
    end
    let!(:event_schedule2) { create(:event_schedule, event: scheduled_event2, schedule: selected_schedule, start_time: (current_time + 1.hour).strftime('%a, %d %b %Y %H:%M:%S')) }
    let!(:scheduled_event3) do
      program.update_attributes!(selected_schedule: selected_schedule)
      create(:event, program: program, state: 'confirmed')
    end
    let!(:event_schedule3) { create(:event_schedule, event: scheduled_event3, schedule: selected_schedule, start_time: (current_time - 1.hour).strftime('%a, %d %b %Y %H:%M:%S')) }
    let!(:scheduled_event4) do
      program.update_attributes!(selected_schedule: selected_schedule)
      create(:event, program: program, state: 'confirmed')
    end
    let!(:event_schedule4) { create(:event_schedule, event: scheduled_event4, schedule: selected_schedule, start_time: (current_time + 2.hours).strftime('%a, %d %b %Y %H:%M:%S')) }

    it 'returns all the events happening at the earliest time in the future but not later or in the past' do
      events_schedules = get_happening_next_events_schedules(conference2)
      expect(events_schedules).to include(event_schedule1)
      expect(events_schedules).to include(event_schedule2)
      expect(events_schedules).to_not include(event_schedule3)
      expect(events_schedules).to_not include(event_schedule4)
    end
  end
end
