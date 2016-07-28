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

    it { is_expected.to validate_presence_of(:amount) }

    it { is_expected.to validate_presence_of(:status) }

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
