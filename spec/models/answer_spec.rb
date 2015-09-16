require 'spec_helper'

describe Answer do
  let(:conference) { create(:conference) }
  let(:question) { create(:question) }
  let(:second_answer) { create(:second_answer) }
  let(:registration) { create(:registration, conference: conference) }

  describe 'validations' do

    it 'has a valid factory' do
      expect(build(:answer)).to be_valid
    end

    it 'is not valid without a title' do
      should validate_presence_of(:title)
      expect(build(:answer, title: nil)).not_to be_valid
    end

    it 'cannot be modified if the question is being used' do
      question.answers << second_answer
      second_answer.title = 'new title'

      expect(second_answer.valid?).to be false
    end

  end

  describe '#sum_replies' do
    before :each do
      conference.questions << question
      registration.qanswers << create(:qanswer, question: question, answer: second_answer)
    end

    it 'returns no of replies for the answer, given a question and a conference' do
      expect(second_answer.sum_replies(question, conference)).to eq 1
    end
  end
end
