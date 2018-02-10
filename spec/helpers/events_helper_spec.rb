require 'spec_helper'

describe EventsHelper, type: :helper do
  let(:conference) { create(:conference) }
  let(:event) { create(:event, program: conference.program) }
  let(:my_vote) { 3 }
  let(:max_rating) { 5 }
  let(:fraction) { my_vote.to_s + '/' + max_rating.to_s }

  setup do
    allow(event).to receive(:average_rating) { my_vote }
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

  describe '#rating_tooltip' do
    let(:vote_count) { pluralize(event.voters.length, 'vote') }

    it 'includes the average rating' do
      expect(rating_tooltip(event, max_rating)).to match(fraction)
    end
    it 'includes the vote count' do
      expect(rating_tooltip(event, max_rating)).to match(vote_count)
    end
  end

  describe '#rating_fraction' do
    it 'represents the rating as a fraction of the max' do
      expect(rating_fraction(my_vote, max_rating)).to match(fraction)
    end

    describe 'rating_stars' do
      it 'renders labels for each value of max_rating' do
        expect(
          rating_stars(my_vote, max_rating).scan('<label class="rating').size
        ).to eq(max_rating)
      end

      it 'renders bright labels for each value of vote' do
        expect(
          rating_stars(my_vote, max_rating).scan('<label class="rating bright').size
        ).to eq(my_vote)
      end
    end
  end
end
