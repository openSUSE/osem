# frozen_string_literal: true

# == Schema Information
#
# Table name: physical_tickets
#
#  id                 :bigint           not null, primary key
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ticket_purchase_id :integer          not null
#
# Indexes
#
#  index_physical_tickets_on_token  (token) UNIQUE
#
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
