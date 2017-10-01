require 'spec_helper'

feature Registration do
  let!(:ticket) { create(:ticket) }
  let!(:free_ticket) { create(:ticket, price_cents: 0) }
  let!(:first_registration_ticket) { create(:registration_ticket, price_cents: 0) }
  let!(:second_registration_ticket) { create(:registration_ticket, price_cents: 0) }
  let!(:conference) { create(:conference, title: 'ExampleCon', tickets: [ticket, free_ticket, first_registration_ticket, second_registration_ticket], registration_period: create(:registration_period, start_date: 3.days.ago)) }
  let!(:participant) { create(:user) }

  context 'as a participant' do
    before(:each) do
      sign_in participant
    end

    after(:each) do
      sign_out
    end

    context 'who is not registered' do

      scenario 'purchases and pays for a ticket succcessfully', feature: true, js: true do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{ticket.id}", with: '2'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'

        expect(current_path).to eq(new_conference_payment_path(conference.short_title))
        expect(flash).to eq('Please pay here to get tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)

        if Rails.application.secrets.stripe_publishable_key
          find('.stripe-button-el').click

          stripe_iframe = all('iframe[name=stripe_checkout_app]').last
          sleep(5)
          Capybara.within_frame stripe_iframe do
            expect(page).to have_content('book your tickets')
            page.execute_script(%{ $('input#card_number').val('4242424242424242'); })
            page.execute_script(%{ $('input#cc-exp').val('08/22'); })
            page.execute_script(%{ $('input#cc-csc').val('123'); })
            page.execute_script(%{ $('#submitButton').click(); })
            sleep(20)
          end

          expect(current_path).to eq(conference_conference_registration_path(conference.short_title))
          expect(page.has_content?("2 #{ticket.title} Tickets for $ 10")).to be true
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

        expect(current_path).to eq(new_conference_payment_path(conference.short_title))
        expect(flash).to eq('Please pay here to get tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)

        if Rails.application.secrets.stripe_publishable_key
          find('.stripe-button-el').click

          stripe_iframe = all('iframe[name=stripe_checkout_app]').last
          sleep(5)
          Capybara.within_frame stripe_iframe do
            expect(page).to have_content('book your tickets')
            page.execute_script(%{ $('input#card_number').val('4000000000000341'); })
            page.execute_script(%{ $('input#cc-exp').val('08/22'); })
            page.execute_script(%{ $('input#cc-csc').val('123'); })
            page.execute_script(%{ $('#submitButton').click(); })
            sleep(20)
          end

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

        expect(flash).to eq('Oops, something went wrong with your purchase! You cannot buy more than one registration tickets.')
        expect(current_path).to eq(conference_tickets_path(conference.short_title))
      end
    end

    context 'who is registered' do

      scenario 'unregisters from conference, but ticket purchases dont delete', feature: true, js: true do
        visit root_path
        click_link 'Register'

        expect(current_path).to eq(new_conference_conference_registration_path(conference.short_title))
        click_button 'Register'

        fill_in "tickets__#{ticket.id}", with: '2'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Continue'

        expect(current_path).to eq(new_conference_payment_path(conference.short_title))
        expect(flash).to eq('Please pay here to get tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)

        if Rails.application.secrets.stripe_publishable_key
          find('.stripe-button-el').click

          stripe_iframe = all('iframe[name=stripe_checkout_app]').last
          sleep(5)
          Capybara.within_frame stripe_iframe do
            expect(page).to have_content('book your tickets')
            page.execute_script(%{ $('input#card_number').val('4242424242424242'); })
            page.execute_script(%{ $('input#cc-exp').val('08/22'); })
            page.execute_script(%{ $('input#cc-csc').val('123'); })
            page.execute_script(%{ $('#submitButton').click(); })
            sleep(20)
          end

          expect(current_path).to eq(conference_conference_registration_path(conference.short_title))
          expect(page.has_content?("2 #{ticket.title} Tickets for $ 10")).to be true

          click_button 'Unregister'
        end

        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)
      end
    end
  end
end
