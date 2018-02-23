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

  describe '#rating_tooltip' do
    let(:max_rating) { 5 }
    let(:event) { create(:event) }
    let(:average_rating) { "#{event.average_rating}/#{max_rating}" }
    let(:vote_count) { pluralize(event.voters.length, 'vote') }

    it 'includes the average rating' do
      expect(rating_tooltip(event, max_rating)).to match(average_rating)
    end
    it 'includes the vote count' do
      expect(rating_tooltip(event, max_rating)).to match(vote_count)
    end
  end
end
