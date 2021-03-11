# frozen_string_literal: true

require 'spec_helper'

feature Registration, feature: true, js: true do
  let!(:ticket) { create(:ticket) }
  let!(:free_ticket) { create(:ticket, price_cents: 0) }
  let!(:first_registration_ticket) { create(:registration_ticket, price_cents: 0) }
  let!(:second_registration_ticket) { create(:registration_ticket, price_cents: 0) }
  let!(:third_registration_ticket) { create(:registration_ticket, price_cents: 2000) }
  let!(:conference) { create(:conference, title: 'ExampleCon', tickets: [ticket, free_ticket, first_registration_ticket, second_registration_ticket, third_registration_ticket], registration_period: create(:registration_period, start_date: 3.days.ago)) }
  let!(:participant) { create(:user) }

  def make_stripe_purchase(card_number='4242424242424242')
    find('.stripe-button-el').click

    stripe_iframe = all('iframe[name=stripe_checkout_app]').last
    sleep(5)
    Capybara.within_frame stripe_iframe do
      expect(page).to have_content(:all, "#{ENV['OSEM_NAME']} tickets")
      fill_in 'Card number', with: card_number
      fill_in 'Expiry', with: '08/22'
      fill_in 'CVC', with: '123'
      click_button '$20.00'
      sleep(20)
    end
  end

  def make_failed_stripe_purchase
    make_stripe_purchase('4000000000000341')
  end

  context 'as a participant' do
    before(:each) do
      sign_in participant
    end

    after(:each) do
      sign_out
    end

    context 'who is not registered' do

      scenario 'purchases and pays for a ticket succcessfully' do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{ticket.id}", with: '2'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'
        page.find('#flash')
        expect(current_path).to eq(new_conference_payment_path(conference.short_title))
        expect(flash).to eq('Please pay here to get tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)

        if ENV['STRIPE_PUBLISHABLE_KEY'] || Rails.application.secrets.stripe_publishable_key
          make_stripe_purchase
          # expect(current_path).to eq(conference_conference_registration_path(conference.short_title))
          expect(current_path).to eq(conference_physical_tickets_path(conference.short_title))
          expect(page).to have_content 'Your ticket is booked successfully.'
        end
      end

      scenario 'purchases ticket but payment fails', feature: true, js: true do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{ticket.id}", with: '2'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'
        page.find('#flash')
        expect(current_path).to eq(new_conference_payment_path(conference.short_title))
        expect(flash).to eq('Please pay here to get tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)

        if ENV['STRIPE_PUBLISHABLE_KEY'] || Rails.application.secrets.stripe_publishable_key
          make_failed_stripe_purchase
          page.find('#flash')
          expect(current_path).to eq(conference_payments_path(conference.short_title))
          expect(flash).to eq('Your card was declined. Please try again with correct credentials.')
        end
      end

      scenario 'purchases free tickets' do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{free_ticket.id}", with: '5'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'

        expect(current_path).to eq(conference_physical_tickets_path(conference.short_title))
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: free_ticket.id).first
        expect(purchase.quantity).to eq(5)
        expect(purchase.paid).to be true
      end

      scenario 'purchases a free registartion ticket' do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{first_registration_ticket.id}", with: '1'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'
        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        expect(flash).to eq('Thanks! Your ticket is booked successfully. Please register for the conference.')

        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: first_registration_ticket.id).first
        expect(purchase.quantity).to eq(1)
        expect(purchase.paid).to be true
      end

      scenario 'purchases a non-free registartion ticket' do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{third_registration_ticket.id}", with: '1'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'
        page.find('#flash')
        expect(current_path).to eq(new_conference_payment_path(conference.short_title))
        expect(flash).to eq('Please pay here to get tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: third_registration_ticket.id).first
        expect(purchase.quantity).to eq(1)

        if ENV['STRIPE_PUBLISHABLE_KEY'] || Rails.application.secrets.stripe_publishable_key
          make_stripe_purchase
          expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
          expect(page).to have_content 'Your ticket is booked successfully.'
        end
      end

      scenario 'purchases more than one registration tickets of a single type' do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{first_registration_ticket.id}", with: '5'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'

        expect(current_path).to eq(conference_tickets_path(conference.short_title))
      end

      scenario 'purchases one registration ticket of a different types' do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{first_registration_ticket.id}", with: '1'
        fill_in "tickets__#{second_registration_ticket.id}", with: '1'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'
        page.find('#flash')
        expect(flash).to eq('Oops, something went wrong with your purchase! You cannot buy more than one registration tickets.')
        expect(current_path).to eq(conference_tickets_path(conference.short_title))
      end
    end

    context 'who is registered' do

      scenario 'unregisters from conference, but ticket purchases dont delete' do
        pending('SNAPCON: Investigate failure on the unregister button')
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{ticket.id}", with: '2'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'
        page.find('#flash')
        expect(current_path).to eq(new_conference_payment_path(conference.short_title))
        expect(flash).to eq('Please pay here to get tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)

        if ENV['STRIPE_PUBLISHABLE_KEY'] || Rails.application.secrets.stripe_publishable_key
          make_stripe_purchase
          # expect(current_path).to eq(conference_conference_registration_path(conference.short_title))
          expect(current_path).to eq(conference_physical_tickets_path(conference.short_title))
          expect(page).to have_content 'Your ticket is booked successfully.'

          click_button 'Unregister'
        end

        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)
      end
    end
  end
end
