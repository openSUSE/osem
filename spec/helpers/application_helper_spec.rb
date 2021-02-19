# frozen_string_literal: true

require 'spec_helper'

describe ApplicationHelper, type: :helper do
  let(:conference) { create(:full_conference) }
  let(:event) { create(:event, program: conference.program) }
  let(:sponsor) { create(:sponsor) }

  describe '#date_string' do
    it 'when conference lasts 1 day' do
      expect(date_string('Sun, 19 Feb 2017'.to_time, 'Sun, 19 Feb 2017'.to_time)).to eq 'February 19 2017'
    end

    it 'when conference starts and ends in the same month and year' do
      expect(date_string('Sun, 19 Feb 2017'.to_time, 'Tue, 28 Feb 2017'.to_time)).to eq 'February 19 - 28, 2017'
    end

    it 'when conference ends in another month, of the same year' do
      expect(date_string('Sun, 19 Feb 2017'.to_time, 'Tue, 28 March 2017'.to_time)).to eq 'February 19 - March 28, 2017'
    end

    it 'when conference ends in another month, of a different year' do
      expect(date_string('Sun, 19 Feb 2017'.to_time, 'Sun, 12 March 2018'.to_time)).to eq 'February 19, 2017 - March 12, 2018'
    end
  end

  describe '#concurrent_events' do
    before :each do
      @other_event = create(:event, program: conference.program, state: 'confirmed')
      schedule = create(:schedule, program: conference.program)
      conference.program.update_attributes!(selected_schedule: schedule)
      @event_schedule = create(:event_schedule, event: event, start_time: conference.start_date + conference.start_hour.hours, room: create(:room), schedule: schedule)
      @other_event_schedule = create(:event_schedule, event: @other_event, start_time: conference.start_date + conference.start_hour.hours, room: create(:room), schedule: schedule)
    end

    describe 'does return correct concurrent events' do
      it 'when events starts at the same time' do
        expect(concurrent_events(event).include?(@other_event)).to eq true
      end

      it 'when event is in between the other event' do
        @event_schedule.update_attributes!(start_time: @other_event_schedule.start_time + 10.minutes)
        expect(concurrent_events(event).include?(@other_event)).to eq true
      end
    end

    describe 'does not return as concurrent event ' do
      it 'when event is not scheduled' do
        @event_schedule.destroy
        expect(concurrent_events(event).present?).to eq false
      end

      it 'when one event starts and other ends at the same time' do
        @event_schedule.update_attributes!(start_time: @other_event_schedule.end_time)
        expect(concurrent_events(event).present?).to eq false
      end

      it 'when conference program does not have a selected schedule' do
        conference.program.update_attributes!(selected_schedule_id: nil)
        expect(concurrent_events(event).present?).to eq false
      end
    end

    describe 'navigation title link' do
      it 'should default to OSEM' do
        ENV.delete('OSEM_NAME')
        # TODO: Snap!Con: expect(nav_root_link_for(nil)).to match 'OSEM'
        expect(nav_root_link_for(nil)).to match image_tag('snapcon_logo.png')
      end

      it 'should use the environment variable' do
        ENV['OSEM_NAME'] = Faker::Company.name + "'"
        # expect(nav_root_link_for(nil)).to match h(ENV['OSEM_NAME'])
        expect(nav_root_link_for(nil)).to match image_tag('snapcon_logo.png')
      end

      it 'should use the conference organization name' do
        # expect(nav_root_link_for(conference)).to match h(conference.organization.name)
        expect(nav_root_link_for(nil)).to match image_tag('snapcon_logo.png')
      end
    end
  end

  describe '#get_logo' do
    context 'first sponsorship_level' do
      before do
        first_sponsorship_level = create(:sponsorship_level, position: 1)
        sponsor.update_attributes(sponsorship_level: first_sponsorship_level)
      end

      it 'returns correct url' do
        expect(get_logo(sponsor)).to match %r{.*(\bfirst/#{sponsor.logo_file_name}\b)}
      end
    end

    context 'second sponsorship_level' do
      before do
        second_sponsorship_level = create(:sponsorship_level, position: 2)
        sponsor.update_attributes(sponsorship_level: second_sponsorship_level)
      end

      it 'returns correct url' do
        expect(get_logo(sponsor)).to match %r{.*(\bsecond/#{sponsor.logo_file_name}\b)}
      end
    end

    context 'other sponsorship_level' do
      before do
        other_sponsorship_level = create(:sponsorship_level, position: 3)
        sponsor.update_attributes(sponsorship_level: other_sponsorship_level)
      end

      it 'returns correct url' do
        expect(get_logo(sponsor)).to match %r{.*(\bothers/#{sponsor.logo_file_name}\b)}
      end
    end

    context 'non-sponsor' do
      it 'returns correct url' do
        expect(get_logo(conference)).to match %r{.*(\blarge/#{conference.logo_file_name}\b)}
      end
    end
  end
end
