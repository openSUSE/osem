# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                 :bigint           not null, primary key
#  amount             :integer
#  authorization_code :string
#  last4              :string
#  status             :integer          default("unpaid"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  conference_id      :integer          not null
#  user_id            :integer          not null
#
require 'spec_helper'
require 'stripe_mock'

describe Payment do

  context 'new payment' do
    let(:payment) { create(:payment) }
    it 'sets status to "unpaid" by default' do
      expect(payment.status).to eq('unpaid')
    end
  end

  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:payment)).to be_valid
    end

    it { is_expected.to validate_presence_of(:status) }

    it { is_expected.to validate_presence_of(:user_id) }

    it { is_expected.to validate_presence_of(:conference_id) }
  end

  describe '#amount_to_pay' do
    let!(:user) { create(:user) }
    let!(:conference) { create(:conference) }
    let(:ticket_1) { create(:ticket, price: 10, price_currency: 'USD', conference: conference) }
    let(:payment) { create(:payment, user: user, conference: conference) }

    it ' returns correct unpaid amount' do
      create(:ticket_purchase, ticket: ticket_1, user: user, quantity: 8)
      expect(payment.amount_to_pay).to eq(8000)
    end
  end

  describe '#purchase' do
    let!(:user) { create(:user) }
    let!(:conference) { create(:conference) }
    let!(:ticket_1) { create(:ticket, price: 10, price_currency: 'USD', conference: conference) }
    let!(:tickets) { {ticket_1.id.to_s => '2'} }
    let(:stripe_helper) { StripeMock.create_test_helper }

    before { StripeMock.start }
    after { StripeMock.stop }

    before { TicketPurchase.purchase(conference, user, tickets) }
    let(:payment) { create(:payment, user: user, conference: conference, stripe_customer_token: stripe_helper.generate_card_token, stripe_customer_email: user.email) }

    context 'when the payment is successful' do
      before { payment.purchase }

      it 'assigns amount' do
        expect(payment.amount).to eq(2000)
      end

      it 'assigns last4' do
        expect(payment.last4).to eq('4242')
      end

      it "assigns 'success' to payment.status" do
        expect(payment.status).to eq('success')
      end

      it 'assigns authorization_code' do
        expect(payment.authorization_code).to eq('test_ch_3')
      end
    end

    context 'if the payment is not successful' do
      let(:payment) { create(:payment, user: user, conference: conference, stripe_customer_token: 'bogus_card_token', stripe_customer_email: user.email) }

      before { payment.purchase }

      context 'when the card is invalid' do
        it 'returns false' do
          payment_result = payment.purchase
          expect(payment_result).to eq false
        end

        it 'assigns "failure" to payment.status' do
          expect(payment.status).to eq('failure')
        end

        it 'adds errors' do
          expect(payment.errors[:base].count).to eq(1)
        end
      end

      context 'when the connection to Stripe drops' do
        it 'raises exception' do
          StripeMock.prepare_error(Stripe::APIConnectionError.new)
          expect{ payment.purchase }.not_to raise_error
        end
      end

      context 'when there is a Stripe API Error' do
        it 'raises exception' do
          StripeMock.prepare_error(Stripe::APIError.new)
          expect{ payment.purchase }.not_to raise_error
        end
      end

      context 'when there is authentication error' do
        it 'raises exception' do
          StripeMock.prepare_error(Stripe::AuthenticationError.new)
          expect{ payment.purchase }.not_to raise_error
        end
      end

      context 'when there is a card error' do
        it 'raises exception' do
          StripeMock.prepare_card_error(:card_declined)
          expect{ payment.purchase }.not_to raise_error
        end
      end

      context 'when the request to Stripe is invalid' do
        it 'raises exception' do
          StripeMock.prepare_error(Stripe::InvalidRequestError.new('Your request is invalid.', code: 402))
          expect{ payment.purchase }.not_to raise_error
        end
      end

      context 'when Stripe rate limit exceeds' do
        it 'raises exception' do
          StripeMock.prepare_error(Stripe::RateLimitError.new)
          expect{ payment.purchase }.not_to raise_error
        end
      end
    end
  end
end
