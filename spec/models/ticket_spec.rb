require 'spec_helper'

describe Ticket do
  let(:conference) { create(:conference) }
  let(:ticket) { create(:ticket, price: 50, price_currency: 'USD', conference: conference) }
  let(:user) { create(:user) }

  describe 'validation' do
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

    it 'is not valid if tickets of conference do not have same currency' do
      conflicting_currency_ticket = build(:ticket,
                                          conference: ticket.conference,
                                          price_currency: 'INR')
      expected_error_message = 'Price currency is different from the existing tickets of this conference.'

      expect(conflicting_currency_ticket).not_to be_valid
      expect(conflicting_currency_ticket.errors.full_messages).to eq([expected_error_message])
    end
  end

  describe 'association' do
    it { should belong_to(:conference) }
    it { should have_many(:ticket_purchases).dependent(:destroy) }
    it { should have_many(:buyers).through(:ticket_purchases).source(:user) }
  end

  describe '#bought?' do
    it 'returns true if the user has bought this ticket' do
      create(:ticket_purchase,
             user: user,
             ticket: ticket)
      expect(ticket.bought?(user)).to eq(true)
    end

    it 'returns false if the user has not bought this ticket' do
      expect(ticket.bought?(user)).to eq(false)
    end
  end

  describe '#paid?' do
    let!(:ticket_purchase) { create(:ticket_purchase, user: user, ticket: ticket) }

    context 'user has paid' do
      before { ticket_purchase.update_attributes(paid: true) }

      it 'returns true' do
        expect(ticket.paid?(user)).to eq(true)
      end
    end

    context 'user has not paid' do
      it 'returns false' do
        expect(ticket.paid?(user)).to eq(false)
      end
    end
  end

  describe '#unpaid?' do
    let!(:ticket_purchase) { create(:ticket_purchase, user: user, ticket: ticket) }

    context 'user has not paid' do

      it 'returns true' do
        expect(ticket.unpaid?(user)).to eq(true)
      end
    end

    context 'user has paid' do
      before { ticket_purchase.update_attributes(paid: true) }

      it 'returns false' do
        expect(ticket.unpaid?(user)).to eq(false)
      end
    end
  end

  describe '#quantity_bought_by' do
    context 'user has not paid' do
      it 'returns the correct value if the user has bought this ticket' do
        create(:ticket_purchase,
               user: user,
               ticket: ticket,
               quantity: 20)
        expect(ticket.quantity_bought_by(user, paid: false)).to eq(20)
      end

      it 'returns zero if the user has not bought this ticket' do
        expect(ticket.quantity_bought_by(user, paid: false)).to eq(0)
      end
    end

    context 'user has paid' do
      let!(:ticket_purchase) { create(:ticket_purchase, user: user, ticket: ticket, quantity: 20) }
      before { ticket_purchase.update_attributes(paid: true) }

      it 'returns the correct value if the user has bought and paid for this ticket' do
        expect(ticket.quantity_bought_by(user, paid: true)).to eq(20)
      end
    end
  end

  describe '#total_price' do
    context 'user has not paid' do
      it 'returns the correct value if the user has bought this ticket' do
        create(:ticket_purchase,
               user: user,
               ticket: ticket,
               quantity: 20)
        expect(ticket.total_price(user, paid: false)).to eq(Money.new(100000, 'USD'))
      end

      it 'returns zero if the user has not bought this ticket' do
        expect(ticket.total_price(user, paid: false)).to eq(Money.new(0, 'USD'))
      end
    end

    context 'user has paid' do
      let!(:ticket_purchase) { create(:ticket_purchase, user: user, ticket: ticket, quantity: 20) }
      before { ticket_purchase.update_attributes(paid: true) }

      it 'returns the correct value if the user has bought this ticket' do
        expect(ticket.total_price(user, paid: true)).to eq(Money.new(100000, 'USD'))
      end
    end
  end

  describe 'self.total_price' do
    let(:diversity_supporter_ticket) { create(:ticket, conference: conference, price: 500) }

    describe 'user has bought' do
      context 'no tickets' do
        it 'returns zero' do
          expect(Ticket.total_price(conference, user, paid: false)).to eq(Money.new(0, 'USD'))
        end
      end

      context 'one type of ticket' do
        before do
          create(:ticket_purchase, ticket: ticket, user: user, quantity: 20)
        end

        it 'returns the correct total price' do
          expect(Ticket.total_price(conference, user, paid: false)).to eq(Money.new(100000, 'USD'))
        end
      end

      context 'multiple types of tickets' do
        before do
          create(:ticket_purchase, ticket: ticket, user: user, quantity: 20)
          create(:ticket_purchase, ticket: diversity_supporter_ticket, user: user, quantity: 2)
        end

        it 'returns the correct total price' do
          total_price = Money.new(200000, 'USD')
          expect(Ticket.total_price(conference, user, paid: false)).to eq(total_price)
        end
      end
    end
  end
end
