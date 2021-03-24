# frozen_string_literal: true

# == Schema Information
#
# Table name: event_types
#
#  id                      :bigint           not null, primary key
#  color                   :string
#  description             :string
#  length                  :integer          default(30)
#  maximum_abstract_length :integer          default(500)
#  minimum_abstract_length :integer          default(0)
#  submission_instructions :text
#  title                   :string           not null
#  created_at              :datetime
#  updated_at              :datetime
#  program_id              :integer
#
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

    it 'is valid if its color is a correct hexadecimal color with 7 characters' do
      should allow_value('#FF0000').for(:color)
    end

    it 'is not valid if its color is not a correct hexadecimal color' do
      should_not allow_value('#AB1H7G').for(:color)
    end

    it 'is not valid if its color has less than 7 characters' do
      should_not allow_value('#fff').for(:color)
    end

    it 'is not valid if its color has more than 7 characters' do
      should_not allow_value('#123A4567').for(:color)
    end

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
