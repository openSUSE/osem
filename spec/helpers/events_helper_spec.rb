require 'spec_helper'

describe EventsHelper, type: :helper do
  let(:conference) { create(:conference) }
  let(:event) { create(:event, program: conference.program) }

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
end
