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

        click_button 'Support'

        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)
        expect(current_path).to eq(conference_conference_registration_path(conference.short_title))
        expect(flash).
            to eq("Thank you for supporting #{conference.title} by purchasing a ticket.")
        expect(page.has_content?("2 #{ticket.title} Tickets for 10")).to be true
      end

      scenario 'deletes a purchased ticket', feature: true, js: true do
        create(:registration, conference: conference, user: participant)
        create(:ticket_purchase, conference: conference, user: participant, ticket: ticket, quantity: 4)

        visit conference_conference_registration_path(conference.short_title)
        expect(page.has_content?("4 #{ticket.title} Tickets for 10")).to be true

        click_link "ticket-#{ticket.id}-delete"
        expect(flash).to eq('Ticket successfully deleted.')
        expect(TicketPurchase.count).to eq(0)
      end
    end
  end
end
