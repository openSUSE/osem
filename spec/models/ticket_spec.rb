require 'spec_helper'

describe Ticket do
  let(:conference) { create(:conference) }
  let(:ticket) { create(:ticket, price: 50, conference: conference) }
  let(:user) { create(:user) }

  describe 'validations' do
    it 'has a valid factory' do
      expect(build(:ticket)).to be_valid
    end

    it 'is not valid without a title' do
      should validate_presence_of(:title)
    end

    it 'is not valid without a price_cents' do
      should validate_presence_of(:price_cents)
    end

    it 'is not valid without a price_currency' do
      should validate_presence_of(:price_currency)
    end

    it 'is not valid with a price_cents equals zero' do
      should_not allow_value(0).for(:price_cents)
    end

    it 'is not valid with a price_cents smaller than zero' do
      should_not allow_value(-1).for(:price_cents)
    end

    it 'is valid with a price_cents greater than zero' do
      should allow_value(1).for(:price_cents)
    end
  end

  describe '#bought?' do
    it 'returns true if the user has bought this ticket' do
      create(:ticket_purchase,
             user: user,
             ticket: ticket)
      expect(ticket.bought?(user)).to eq(true)
    end

    it 'returns true if the user has bought this ticket' do
      expect(ticket.bought?(user)).to eq(false)
    end
  end

  describe '#quantity_bought_by' do
    it 'returns the correct value if the user has bought this ticket' do
      create(:ticket_purchase,
             user: user,
             ticket: ticket,
             quantity: 20)
      expect(ticket.quantity_bought_by(user)).to eq(20)
    end

    it 'returns zero if the user has not bought this ticket' do
      expect(ticket.quantity_bought_by(user)).to eq(0)
    end
  end

  describe '#total_price' do
    it 'returns the correct value if the user has bought this ticket' do
      create(:ticket_purchase,
             user: user,
             ticket: ticket,
             quantity: 20)
      expect(ticket.total_price(user)).to eq(20 * 50)
    end

    it 'returns zero if the user has not bought this ticket' do
      expect(ticket.total_price(user)).to eq(0)
    end
  end

  describe 'self#total_price' do
    it 'returns the correct value if the user has bought this ticket' do
      create(:ticket_purchase,
             user: user,
             ticket: ticket,
             quantity: 20)
      expect(Ticket.total_price(conference, user)).to eq(20 * 50)
    end

    it 'returns zero if the user has not bought this ticket' do
      expect(Ticket.total_price(conference, user)).to eq(0)
    end
  end
end
