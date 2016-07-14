require 'spec_helper'

describe Payment do

  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:payment)).to be_valid
    end

    it { is_expected.to validate_presence_of(:first_name) }

    it { is_expected.to validate_presence_of(:last_name) }

    it { is_expected.to validate_presence_of(:credit_card_number) }

    it { is_expected.to validate_presence_of(:card_verification_value) }

    it { is_expected.to validate_presence_of(:expiration_month) }

    it { is_expected.to validate_presence_of(:expiration_year) }

    it { is_expected.to validate_presence_of(:amount) }

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

  describe 'purchase' do
    let!(:participant) { create(:user) }
    let!(:ticket_1) { create(:ticket) }
    let!(:conference) { create(:conference, tickets: [ticket_1]) }

    it 'creates no ticket purchase or payment if amount is less than 1' do
      tickets = { ticket_1.id.to_s => '-1' }
      TicketPurchase.purchase(conference, participant, tickets)

      expect(TicketPurchase.count).to eq(0)
      expect(Payment.count).to eq(0)
    end

    it 'creates no ticket purchase or payment if amount is 0' do
      tickets = { ticket_1.id.to_s => '0' }
      TicketPurchase.purchase(conference, participant, tickets)

      expect(TicketPurchase.count).to eq(0)
      expect(Payment.count).to eq(0)
    end

    let(:payment) { create(:payment) }
    it 'creates a purchase and payment for one ticket' do
      tickets = { ticket_1.id.to_s => '1' }
      message = TicketPurchase.purchase(conference, participant, tickets)
      purchase = TicketPurchase.where(conference_id: conference.id,
                                      user_id: participant.id,
                                      ticket_id: ticket_1.id).first

      expect(TicketPurchase.count).to eq(1)
      # expect(purchase.quantity).to eq(1)
      expect(message.blank?).to be true

     payment = Payment.new
     payment.purchase(participant, conference, 1000)

      expect(Payment.count).to eq(1)
      expect(payment.blank?).to be true
    end
  end
end
