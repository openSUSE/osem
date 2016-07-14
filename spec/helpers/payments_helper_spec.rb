require 'spec_helper'

describe PaymentsHelper, type: :helper do
  let(:conference) { create(:conference) }
  let(:event) { create(:event, program: conference.program) }

  describe '#months' do
    it 'returns the correct strings for months' do
      expect(months).to match_array(Array([["1 - January", 1], ["2 - February", 2], ["3 - March", 3],
                                           ["4 - April", 4], ["5 - May", 5], ["6 - June", 6],
                                           ["7 - July", 7], ["8 - August", 8], ["9 - September", 9],
                                           ["10 - October", 10], ["11 - November", 11], ["12 - December", 12]]))
    end
  end

  describe '#years' do
    it 'returns the correct set of options' do
      expect(years).to match_array(Array(Date.current.year..Date.current.year + 15))
    end
  end

  describe '#card_types' do
    it 'returns the correct set of card_types array' do
      expect(card_types).to match_array(Array([["American Express", "american_express"], ["Discover", "discover"],
                                               ["MasterCard", "master"], ["Visa", "visa"]]))
    end
  end
end
