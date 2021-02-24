# frozen_string_literal: true

# == Schema Information
#
# Table name: ticket_scannings
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  physical_ticket_id :integer          not null
#
require 'spec_helper'

describe TicketScanning do
  let(:conference) { create(:conference) }
  let(:user) { create(:user) }
  let(:registration) { create(:registration, conference: conference, user: user) }
  let(:registration_ticket) { create(:registration_ticket, conference: conference) }
  let(:paid_ticket_purchase) { create(:paid_ticket_purchase, conference: conference, user: user, ticket: registration_ticket, quantity: 1) }
  let(:physical_ticket) { create(:physical_ticket, ticket_purchase: paid_ticket_purchase) }
  let(:ticket_scanning) { create(:ticket_scanning, physical_ticket: physical_ticket) }

  describe 'before_create' do
    it 'marks user as present' do
      expect(registration.attended).to eq(false)
      ticket_scanning
      registration.reload
      expect(registration.attended).to eq(true)
    end
  end
end
