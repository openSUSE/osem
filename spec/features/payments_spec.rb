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

      scenario 'purchases and pays for a ticket, with gateway producing error', feature: true, js: true do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{ticket.id}", with: '2'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'

        expect(current_path).to eq(new_conference_payment_path(conference.short_title))
        expect(flash).to eq('Please pay here to purchase tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)

        fill_in 'full_name', with: 'foo'
        select Date.current.year + 2, from: 'expiration_year'
        fill_in 'card_verification_value', with: '123'
        fill_in 'credit_card_number', with: '4242424242423333'

        click_button 'Charge Card'

        expect(Payment.count).to eq(0)
      end

      scenario 'purchases and pays for a ticket, with card producing a transaction failure', feature: true, js: true do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{ticket.id}", with: '2'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'

        expect(current_path).to eq(new_conference_payment_path(conference.short_title))
        expect(flash).to eq('Please pay here to purchase tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)

        fill_in 'full_name', with: 'foo'
        select Date.current.year + 2, from: 'expiration_year'
        fill_in 'card_verification_value', with: '123'
        fill_in 'credit_card_number', with: '4242424242422222'

        click_button 'Charge Card'

        expect(Payment.count).to eq(0)
      end

      scenario 'purchases and pays for a ticket successfully', feature: true, js: true do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{ticket.id}", with: '2'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'

        expect(current_path).to eq(new_conference_payment_path(conference.short_title))
        expect(flash).to eq('Please pay here to purchase tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)

        fill_in 'full_name', with: 'foo'
        select Date.current.year + 2, from: 'expiration_year'
        fill_in 'card_verification_value', with: '123'
        fill_in 'credit_card_number', with: '4242424242421111'

        click_button 'Charge Card'

        expect(current_path).to eq(conference_conference_registration_path(conference.short_title))
        expect(Payment.count).to eq(1)
        payment = Payment.where(user_id: participant, conference_id: conference.id).first
        expect(payment.amount).to eq(20)
        expect(payment.status).to eq('success')
        expect(payment.first_name).to eq('foo')
        expect(payment.last_name).to eq('bar')
        expect(payment.last4).not_to be_empty
        expect(payment.authorization_code).not_to be_empty
        expect(flash).to eq('Thanks! You have purchased your tickets successfully.')
      end
    end
  end
end
