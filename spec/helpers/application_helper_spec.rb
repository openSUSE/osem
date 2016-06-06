require 'spec_helper'

describe ApplicationHelper, type: :helper do
  let(:conference) { create(:conference) }
  let(:event) { create(:event, program: conference.program) }

  describe 'show_roles' do
    it 'formats the hash passed' do
      roles = { 'organizer' => ['oSC16', 'oSC15'], 'cfp' => ['oSC16'] }
      expect(show_roles(roles)).to eq 'Organizer (oSC16, oSC15), Cfp (oSC16)'
    end
  end

  describe '#registered_text' do
    describe 'returns correct string' do
      before :each do
        event.require_registration = true
        event.max_attendees = 3
      end

      it 'when there are no registrations' do
        expect(registered_text(event)).to eq '0/3'
      end

      it 'when there is 1 registration' do
        event.registrations << create(:registration)
        expect(registered_text(event)).to eq '1/3'
      end
    end
  end
end
