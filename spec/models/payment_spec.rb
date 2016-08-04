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
end
