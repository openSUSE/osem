require 'spec_helper'

feature Registration do
  let!(:ticket) { create(:ticket) }
  let!(:conference) { create(:conference, title: 'ExampleCon', tickets: [ticket]) }
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
        click_link 'Support'

        fill_in "tickets__#{ticket.id}", with: '2'
        expect(current_path).to eq(conference_tickets_path(conference.short_title))

        click_button 'Support'

        purchase = TicketPurchase.where(user_id: participant.id, ticket_id: ticket.id).first
        expect(purchase.quantity).to eq(2)
        expect(current_path).to eq(conference_conference_registrations_path(conference.short_title))
        expect(flash).
            to eq('Congratulations, you have successfully purchased a ticket! You can pay it cash on check in! Thank you for supporting ExampleCon!')
        expect(page.has_content?('Business Ticket')).to be true
      end

      scenario 'deletes a purchased ticket', feature: true, js: true do
        create(:ticket_purchase,
               user_id: participant.id,
               ticket_id: ticket.id,
               quantity: 2)

        visit conference_conference_registrations_path(conference.short_title)
        expect(page.has_content?('Business Ticket')).to be true

        click_link 'Delete'
        expect(flash).to eq('Ticket successfully destroyed.')
        expect(TicketPurchase.count).to eq(0)
      end
    end
  end
end
