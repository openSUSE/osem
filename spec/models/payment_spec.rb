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

  describe '#purchase' do
    let!(:user) { create(:user) }
    let!(:ticket_1) { create(:ticket) }
    let!(:conference) { create(:conference, tickets: [ticket_1]) }
    let(:payment) { create(:payment) }

    it 'calls the payment gateway with the correct parameters' do
      expect(GATEWAY).to receive(:purchase).with(1000, payment.credit_card, currency: 'USD')
        .and_return(ActiveMerchant::Billing::Response.new(true, 'Success.'))

      payment.purchase(user, conference, 1000)
    end

    context 'when the payment is successful' do
      before { payment.purchase(user, conference, 1000) }

      it 'returns true' do
        payment_result = payment.purchase(user, conference, 1000)
        expect(payment_result).to eq true
      end

      it "assigns 'success' to payment.status" do
        expect(payment.status).to eq('success')
      end

      it 'assigns user_id' do
        expect(payment.user_id).to eq(user.id)
      end

      it 'assigns conference_id' do
        expect(payment.conference_id).to eq(conference.id)
      end

      it 'assigns last4' do
        expect(payment.last4).to eq('XXXX-XXXX-XXXX-4111')
      end

      it 'assigns authorization_code' do
        expect(payment.authorization_code).to eq("53433")
      end
    end

    context 'if the payment is not successful' do
      before { payment.purchase(user, conference, 1000) }

      let(:payment) { create(:payment, :invalid_credit_card) }

      context 'when the card is invalid' do
        it 'returns false' do
          payment_result = payment.purchase(user, conference, 1000)
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
          payment_result = payment.purchase(user, conference, 1000)
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

