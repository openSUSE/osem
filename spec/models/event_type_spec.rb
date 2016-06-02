require 'spec_helper'

describe EventType do
  let(:conference) { create(:conference) }
  let(:event_type) { create(:event_type, program: conference.program) }

  describe 'association' do
    it { is_expected.to belong_to :program }
    it { is_expected.to have_many :events }
  end

  describe 'validation' do
    it 'has a valid factory' do
      expect(build(:event_type)).to be_valid
    end

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:minimum_abstract_length) }
    it { is_expected.to validate_presence_of(:maximum_abstract_length) }

    describe 'length' do
      it 'validates numericality and greater than 0' do
        is_expected.to validate_numericality_of(:length).is_greater_than(0)
      end

      it 'is valid when length is multiple of LENGTH_STEP' do
        expect(build(:event_type, program: conference.program, length: 30)).to be_valid
      end

      it 'is not valid when length is not multiple of LENGTH_STEP' do
        expect(build(:event_type, program: conference.program, length: 37)).not_to be_valid
      end
    end
  end
end
