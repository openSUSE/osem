require 'spec_helper'

feature Registration do
  let!(:ticket) { create(:ticket) }
  let!(:conference) { create(:conference, title: 'ExampleCon', tickets: [ticket], registration_period: create(:registration_period, start_date: 3.days.ago)) }
  let!(:participant) { create(:user) }

  context 'as a participant' do
    before(:each) do
      sign_in participant
    end

    after(:each) do
      sign_out
    end

    context 'who is not registered' do

      scenario 'purchases a ticket', feature: true, js: true do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{ticket.id}", with: '2'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'

        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)
        expect(current_path).to eq(new_conference_payment_path)
        expect(flash).
            to eq('Please pay here to purchase tickets.')

        fill_in 'first_name', with: 'foo'
        fill_in 'last_name', with: 'bar'
        fill_in 'expiration_year', Date.current.year + 2
        fill_in 'card_verification_value', with: '123'
        fill_in 'credit_card_number', with: '4242424242424242'

        click_button 'Charge Card'

        payment = Payment.where(user_id: participant, conference_id: conference.id).first
        expect(payment.amount).to eq(20)
        expect(payment.status).to eq(1)
        expect(payment.first_name).to eq('foo')
        expect(payment.first_name).to eq('bar')
        expect(payment.last4).not_to be_empty
        expect(payment.authorization_code).not_to be_empty
        expect(current_path).to eq(conference_conference_registrations_path(conference.short_title))
        expect(flash).
            to eq('Thanks! You have purchased your tickets successfully.')

        expect(page.has_content?("2 #{ticket.title} Tickets for 10")).to be true
      end
    end
  end
end
