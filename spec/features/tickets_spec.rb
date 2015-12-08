require 'spec_helper'

feature Ticket do
  let!(:conference) { create(:conference, title: 'ExampleCon') }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, email: 'admin@example.com', role_ids: [organizer_role.id]) }

  context 'as a organizer' do
    before(:each) do
      sign_in organizer
    end

    after(:each) do
      sign_out
    end

    scenario 'add a valid ticket', feature: true, js: true do
      visit admin_conference_tickets_path(conference.short_title)
      click_link 'Add Ticket'

      fill_in 'ticket_title', with: 'Business Ticket'
      fill_in 'ticket_description', with: 'The business ticket'
      fill_in 'ticket_price', with: '100'

      click_button 'Create Ticket'
      expect(flash).to eq('Ticket successfully created.')
      expect(Ticket.count).to eq(1)
    end

    scenario 'add a invalid ticket', feature: true, js: true do
      visit admin_conference_tickets_path(conference.short_title)
      click_link 'Add Ticket'

      fill_in 'ticket_title', with: ''
      fill_in 'ticket_price', with: '-1'

      click_button 'Create Ticket'
      expect(Ticket.count).to eq(0)
    end

    context 'Ticket already created' do
      let!(:ticket) { create(:ticket, title: 'Business Ticket', price: 100, conference_id: conference.id) }

      scenario 'edit valid ticket', feature: true, js: true do
        visit admin_conference_tickets_path(conference.short_title)
        click_link 'Edit'

        fill_in 'ticket_title', with: 'Free Ticket'
        fill_in 'ticket_price', with: '50'

        click_button 'Update Ticket'

        ticket.reload
        expect(ticket.price).to eq(50)
        expect(ticket.title).to eq('Free Ticket')
        expect(flash).to eq('Ticket successfully updated.')
        expect(Ticket.count).to eq(1)
      end

      scenario 'edit invalid ticket', feature: true, js: true do
        visit admin_conference_tickets_path(conference.short_title)
        click_link 'Edit'

        fill_in 'ticket_title', with: ''
        fill_in 'ticket_price', with: '-5'

        click_button 'Update Ticket'

        ticket.reload
        expect(ticket.price).to eq(100)
        expect(ticket.title).to eq('Business Ticket')
        expect(Ticket.count).to eq(1)
      end

      scenario 'delete ticket', feature: true, js: true do
        visit admin_conference_tickets_path(conference.short_title)
        click_link 'Delete'

        expect(flash).to eq('Ticket successfully destroyed.')
        expect(Ticket.count).to eq(0)
      end
    end
  end
end
