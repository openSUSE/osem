# frozen_string_literal: true

require 'spec_helper'

describe Commercial do

  it { should validate_presence_of(:url) }

  it 'validates url format' do
    commercial = build(:conference_commercial, url: 'ftp://example.com')
    expect(commercial.valid?).to be false
    expect(commercial.errors['url']).to eq ['is invalid']
  end

  it 'validates url rendering' do
    commercial = build(:conference_commercial)
    expect(commercial.valid?).to be true
  end
end
