# frozen_string_literal: true

require 'spec_helper'

describe PhysicalTicket do

  describe 'association' do
    it { is_expected.to belong_to :ticket_purchase }
  end

  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:physical_ticket)).to be_valid
    end
  end
end
