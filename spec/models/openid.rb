# frozen_string_literal: true

require 'spec_helper'

describe Openid do
  subject { create(:openid) }

  describe 'validation' do
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe 'association' do
    it { is_expected.to belong_to(:user) }
  end
end
