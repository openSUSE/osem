require 'spec_helper'
require 'stripe_mock'

feature Registration do
  let!(:ticket) { create(:ticket) }
  let!(:conference) { create(:conference, title: 'ExampleCon', tickets: [ticket], registration_period: create(:registration_period, start_date: 3.days.ago)) }
  let!(:participant) { create(:user) }

  context 'as a participant' do
    before(:each) do
      sign_in participant
      StripeMock.start
    end

    after(:each) do
      StripeMock.stop
      sign_out
    end

    let(:stripe_helper) { StripeMock.create_test_helper }

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
        expect(flash).to eq('Please pay here to purchase tickets.')
        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)

        # token = stripe_helper.generate_card_token
        # merge token, email and submit form
        # page.execute_script("$('form').submit()")

        expect(current_path).to eq(conference_conference_registration_path(conference.short_title))
      end
    end
  end
end
