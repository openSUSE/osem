require 'spec_helper'

describe ApplicationHelper, type: :helper do
  let(:conference) { create(:conference) }
  let(:event) { create(:event, program: conference.program) }

  describe 'format_datetme' do
    it 'returns nothing if there is no parameter' do
      expect(format_datetime(nil)).to eq nil
    end

    it 'returns formatted string' do
      datetime = Time.zone.local(2016, 05, 04, 11, 30)
      expect(format_datetime(datetime)).to eq '2016-05-04 11:30'
    end
  end

  describe 'show_time' do
    it 'when length > 60' do
      expect(show_time(67)).to eq '1 h 7 min'
    end

    it 'when length = 60' do
      expect(show_time(60)).to eq '1 h'
    end

    it 'when length < 60' do
      expect(show_time(58)).to eq '58 min'
    end

    it 'when length > 60 and is a decimal number' do
      expect(show_time(68.3)).to eq '1 h 8 min'
    end

    it 'when length is nil' do
      expect(show_time(nil)).to eq '0 h 0 min'
    end
  end

  describe 'show_roles' do
    it 'formats the hash passed' do
      roles = { 'organizer' => ['oSC16', 'oSC15'], 'cfp' => ['oSC16'] }
      expect(show_roles(roles)).to eq 'Organizer (oSC16, oSC15), Cfp (oSC16)'
    end
  end

  describe 'markdown' do
    it 'should return empty string for nil' do
      expect(markdown(nil)).to eq ''
    end

    it 'should return HTML for header markdown' do
      expect(Redcarpet::Markdown).to receive(:new)
        .with(Redcarpet::Render::HTML, autolink: true,
                                       space_after_headers: true,
                                       no_intra_emphasis: true)
        .and_call_original

      expect(markdown('# this is my header')).to eq "<h1>this is my header</h1>\n"
    end
  end

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

  describe '#registered_text' do
    describe 'returns correct string' do
      it 'when there are no registrations' do
        expect(registered_text(event)).to eq 'Registered: 0'
      end

      it 'when there is 1 registration' do
        event.require_registration = true
        event.max_attendees = 3
        event.registrations << create(:registration, user: event.submitter)
        expect(registered_text(event)).to eq 'Registered: 1/3'
      end
    end
  end

  describe '#concurrent_events' do
    before :each do
      @other_event = create(:event, program: conference.program, state: 'confirmed')
      schedule = create(:schedule, program: conference.program)
      conference.program.update_attributes!(selected_schedule: schedule)
      @event_schedule = create(:event_schedule, event: event, start_time: conference.start_date, room: create(:room), schedule: schedule)
      @other_event_schedule = create(:event_schedule, event: @other_event, start_time: conference.start_date, room: create(:room), schedule: schedule)
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
  end
end
