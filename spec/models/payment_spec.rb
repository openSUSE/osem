require 'spec_helper'

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

    it { is_expected.to validate_presence_of(:first_name) }

    it { is_expected.to validate_presence_of(:last_name) }

    it { is_expected.to validate_presence_of(:credit_card_number) }

    it { is_expected.to validate_presence_of(:card_verification_value) }

    it { is_expected.to validate_presence_of(:expiration_month) }

    it { is_expected.to validate_presence_of(:expiration_year) }

    it { is_expected.to validate_presence_of(:amount) }

    it { is_expected.to validate_presence_of(:user_id) }

    it { is_expected.to validate_presence_of(:conference_id) }

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

  describe '#credit_card' do
    let(:payment) { create(:payment) }

    it 'assigns correct "month"' do
      expect(payment.credit_card.month).to eq(6)
    end

    it 'assigns correct "year"' do
      expect(payment.credit_card.year).to eq(Date.current.year + 2)
    end

    it 'assigns correct "verification_value"' do
      expect(payment.credit_card.verification_value).to eq('123')
    end

    it 'assigns correct "card_number"' do
      expect(payment.credit_card.display_number).to eq('XXXX-XXXX-XXXX-4111')
    end
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
    let!(:ticket_1) { create(:ticket) }
    let!(:conference) { create(:conference, tickets: [ticket_1]) }
    let!(:payment) { create(:payment, user: user, conference: conference) }

    let!(:tickets) { {ticket_1.id.to_s => '1'} }

    before { TicketPurchase.purchase(conference, user, tickets) }

    context 'when the payment is successful' do
      before { payment.purchase }

      it 'returns true' do
        payment_result = payment.purchase
        expect(payment_result).to eq true
      end

      it "assigns 'success' to payment.status" do
        expect(payment.status).to eq('success')
      end

      it 'assigns last4' do
        expect(payment.last4).to eq('XXXX-XXXX-XXXX-4111')
      end

      it 'assigns authorization_code' do
        expect(payment.authorization_code).to eq('53433')
      end
    end

    context 'if the payment is not successful' do
      before { payment.purchase }

      let(:payment) { create(:payment, :invalid_credit_card) }

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

      context 'when there is a connection problem with the gateway' do
        let(:payment) { create(:payment, :exception_credit_card) }

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
    end
  end
end
