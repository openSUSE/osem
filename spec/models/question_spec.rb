require 'spec_helper'

describe Question do

  describe 'validations' do

    it 'has a valid factory' do
      expect(build(:question)).to be_valid
    end

    it 'is not valid without a title' do
      should validate_presence_of(:title)
      expect(build(:question, title: nil)).not_to be_valid
    end

    it 'is not valid without a question type' do
      should validate_presence_of(:question_type_id)
      expect(build(:question, question_type_id: nil)).not_to be_valid
    end

  end
end
