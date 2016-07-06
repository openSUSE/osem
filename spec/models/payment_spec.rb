require 'spec_helper'

describe Payment do

  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:payment)).to be_valid
    end

    it 'is not valid without a first_name' do
      should validate_presence_of(:first_name)
    end

    it 'is not valid without a last_name' do
      should validate_presence_of(:last_name)
    end

    it 'is not valid without a credit_card_number' do
      should validate_presence_of(:credit_card_number)
    end

    it 'is not valid without a card_verification_value' do
      should validate_presence_of(:card_verification_value)
    end

    it 'is not valid without a expiration_month' do
      should validate_presence_of(:expiration_month)
    end

    it 'is not valid without a expiration_year' do
      should validate_presence_of(:expiration_year)
    end

    it 'is not valid without a amount' do
      should validate_presence_of(:amount)
    end

    it 'is not valid with a amount equals zero' do
      should_not allow_value(0).for(:amount)
    end

    it 'is not valid with a amount smaller than zero' do
      should_not allow_value(-1).for(:amount)
    end

    it 'is valid with a amount greater than zero' do
      should allow_value(1).for(:amount)
    end

  end

  describe 'self#purchase' do
    let!(:participant) { create(:user) }
    let!(:ticket_1) { create(:ticket) }
    let!(:ticket_2) { create(:ticket) }
    let!(:conference) { create(:conference, tickets: [ticket_1, ticket_2]) }

    it 'creates a purchase and payment for one ticket' do
      tickets = { ticket_1.id.to_s => '1' }
      message = TicketPurchase.purchase(conference, participant, tickets)
      purchase = TicketPurchase.where(conference_id: conference.id,
                                      user_id: participant.id,
                                      ticket_id: ticket_1.id).first

      expect(TicketPurchase.count).to eq(1)
      expect(purchase.quantity).to eq(1)
      expect(message.blank?).to be true

      response = Payment.purchase(participant, conference, 1000)
      payment = Payment.where(conference_id: conference.id,
                              user_id: participant.id)

      expect(Payment.count).to eq(1)
      expect(payment.amount).to eq(10)
      expect(response.blank?).to be true
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

      response = Payment.purchase(participant, conference, 2000)
      payment = Payment.where(conference_id: conference.id,
                              user_id: participant.id)

      expect(Payment.count).to eq(1)
      expect(payment.amount).to eq(20)
      expect(response.blank?).to be true
    end

    it 'creates no ticket purchase or payment if amount is less than 1' do
      tickets = { ticket_1.id.to_s => '-1' }
      TicketPurchase.purchase(conference, participant, tickets)

      expect(TicketPurchase.count).to eq(0)
    end

    it 'creates no ticket purchase or payment if amount is 0' do
      tickets = { ticket_1.id.to_s => '0' }
      TicketPurchase.purchase(conference, participant, tickets)

      expect(TicketPurchase.count).to eq(0)
    end
  end
end
