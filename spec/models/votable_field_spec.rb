require 'spec_helper'

describe VotableField do
  subject { create(:votable_field) }

  describe 'validations' do

    it 'has a valid factory' do
      expect(build(:votable_field)).to be_valid
    end

    it 'is not valid without a title' do
      subject.title = ''
      expect(subject).to be_invalid
    end

    it 'is not valid without a votable field' do
      should validate_presence_of(:votable_type)
    end

    it 'is valid with title containing special characters but not spaces' do
      should allow_value('example-votable&field').for(:title)
    end

    it 'is not valid with title containing spaces' do
      should_not allow_value('example votable field').for(:title)
    end

    it 'is not valid with unsupported votable_type' do
      should_not allow_value('unsupported').for(:votable_type)
    end

    it 'is valid for supported votable types' do
      should allow_value('Event').for(:votable_type)
    end
  end
end
