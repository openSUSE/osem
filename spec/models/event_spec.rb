require 'spec_helper'

describe Event do

  describe 'abstract_word_count' do
    it 'counts words in abstract' do
      event = build(:event)
      expect(event.abstract_word_count).to eq(233)
      event.update_attributes!(abstract: "abstract.")
      expect(event.abstract_word_count).to eq(1)
    end

    it 'counts 0 when abstract is empty' do
      event = build(:event, abstract: nil)
      expect(event.abstract_word_count).to eq(0)
      event.abstract = ""
      expect(event.abstract_word_count).to eq(0)
    end
  end
end
