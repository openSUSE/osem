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

  describe 'show_roles' do
    it 'formats the hash passed' do
      roles = { 'organizer' => ['oSC16', 'oSC15'], 'cfp' => ['oSC16'] }
      expect(show_roles(roles)).to eq 'Organizer (oSC16, oSC15), Cfp (oSC16)'
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
end
