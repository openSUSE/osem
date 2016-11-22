require 'spec_helper'

describe TicketPurchase do

  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:ticket_purchase)).to be_valid
    end

    it 'is not valid without a conference_id' do
      should validate_presence_of(:conference_id)
    end

    it 'is not valid without a ticket_id' do
      should validate_presence_of(:ticket_id)
    end

    it 'is not valid without a user_id' do
      should validate_presence_of(:user_id)
    end

    it 'is not valid without a quantity' do
      should validate_presence_of(:quantity)
    end

    it 'is not valid with a quantity equals zero' do
      should_not allow_value(0).for(:quantity)
    end

    it 'is not valid with a quantity smaller than zero' do
      should_not allow_value(-1).for(:quantity)
    end

    it 'is valid with a quantity greater than zero' do
      should allow_value(1).for(:quantity)
    end

  end

  describe 'self#purchase' do
    let!(:participant) { create(:user) }
    let!(:ticket_1) { create(:ticket) }
    let!(:ticket_2) { create(:ticket) }
    let!(:free_ticket) { create(:ticket, price_cents: 0) }
    let!(:conference) { create(:conference, tickets: [ticket_1, ticket_2, free_ticket]) }

    it 'creates purchase to free ticket' do
      tickets = { free_ticket.id.to_s => '10' }
      message = TicketPurchase.purchase(conference, participant, tickets)
      purchase = TicketPurchase.where(conference_id: conference.id,
                                      user_id: participant.id,
                                      ticket_id: free_ticket.id).first

      expect(TicketPurchase.count).to eq(1)
      expect(purchase.quantity).to eq(10)
      expect(message.blank?).to be true

    end

    it 'creates a purchase for one ticket' do
      tickets = { ticket_1.id.to_s => '1' }
      message = TicketPurchase.purchase(conference, participant, tickets)
      purchase = TicketPurchase.where(conference_id: conference.id,
                                      user_id: participant.id,
                                      ticket_id: ticket_1.id).first

      expect(TicketPurchase.count).to eq(1)
      expect(purchase.quantity).to eq(1)
      expect(message.blank?).to be true
    end

    it 'creates several purchases for more than one ticket' do
      tickets = { ticket_1.id.to_s => '1', ticket_2.id.to_s => '1' }
      message = TicketPurchase.purchase(conference, participant, tickets)
      purchase_1 = TicketPurchase.where(conference_id: conference.id,
                                        user_id: participant.id,
                                        ticket_id: ticket_1.id).first

      purchase_2 = TicketPurchase.where(conference_id: conference.id,
                                        user_id: participant.id,
                                        ticket_id: ticket_2.id).first

      expect(TicketPurchase.count).to eq(2)
      expect(purchase_1.quantity).to eq(1)
      expect(purchase_2.quantity).to eq(1)
      expect(message.blank?).to be true
    end

    it 'creates no purchase if quantity is less than 1' do
      tickets = { ticket_1.id.to_s => '-1' }
      TicketPurchase.purchase(conference, participant, tickets)

      expect(TicketPurchase.count).to eq(0)
    end

    it 'creates no purchase if quantity is 0' do
      tickets = { ticket_1.id.to_s => '0' }
      TicketPurchase.purchase(conference, participant, tickets)

      expect(TicketPurchase.count).to eq(0)
    end

    it 'updates the quantity if the user already bought this ticket' do
      purchase = create(:ticket_purchase,
                        conference: conference,
                        user: participant,
                        ticket: ticket_1,
                        quantity: 5)

      tickets = { ticket_1.id.to_s => '10' }
      message = TicketPurchase.purchase(conference, participant, tickets)
      purchase.reload

      expect(TicketPurchase.count).to eq(1)
      expect(purchase.quantity).to eq(10)
      expect(message.blank?).to be true
    end
  end
end
