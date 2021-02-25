# frozen_string_literal: true

# == Schema Information
#
# Table name: sponsorship_levels
#
#  id            :bigint           not null, primary key
#  position      :integer
#  title         :string
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#
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
        .to eq [@second_sponsorship_level.id, @first_sponsorship_level.id, @third_sponsorship_level.id]
    end

    it 'maintains order after deleting one element' do
      @first_sponsorship_level.destroy
      expect(SponsorshipLevel.where(conference_id: conference.id).order(:position).map(&:id))
        .to eq [@second_sponsorship_level.id, @third_sponsorship_level.id]
    end
  end
end
