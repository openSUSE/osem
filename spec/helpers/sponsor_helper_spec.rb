require 'spec_helper'

describe SponsorsHelper, type: :helper do
  let(:sponsor) { create(:sponsor) }

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
  end
end
