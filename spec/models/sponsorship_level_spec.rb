require 'spec_helper'

describe SponsorshipLevel do
  describe 'validation' do

    it 'has a valid factory' do
      expect(build(:sponsorship_level)).to be_valid
    end

    it 'is not valid without a title' do
      should validate_presence_of(:title)
    end
  end

  describe 'association' do
    it { is_expected.to belong_to(:conference) }
    it { is_expected.to have_many(:sponsors) }
  end

  describe 'acts_as_list' do
    let(:conference) { create(:conference) }

    before do
      @first_sponsorship_level = create(:sponsorship_level, conference: conference)
      @second_sponsorship_level = create(:sponsorship_level, conference: conference)
      @second_sponsorship_level.move_higher
      @third_sponsorship_level = create(:sponsorship_level, conference: conference)
    end

    it 'is positions sponsorship_levels in order' do
      expect(SponsorshipLevel.where(conference_id: conference.id).order(:position).map(&:id))
        .to eq [2, 1, 3]
    end

    it 'maintains order after deleting one element' do
      @first_sponsorship_level.destroy
      expect(SponsorshipLevel.where(conference_id: conference.id).order(:position).map(&:id))
        .to eq [2, 3]
    end
  end
end
