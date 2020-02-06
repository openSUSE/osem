# frozen_string_literal: true

require 'spec_helper'

describe Admin::TicketsController do
  let(:admin) { create(:admin) }
  let(:conference) { create(:conference) }
  let!(:ticket) { create(:ticket, conference: conference) }
  let(:new_title) { Faker::Hipster.sentence }

  context 'admin is signed in' do
    before { sign_in admin }

    describe 'GET #index' do
      before { get :index, params: { conference_id: conference } }

      it 'assigns conference and tickets variables via cancancan' do
        expect(assigns(:conference)).to eq conference
        expect(assigns(:tickets)).to eq conference.tickets
      end

      it 'renders index template' do
        expect(response).to render_template('index')
      end
    end

    describe 'GET #edit' do
      before { get :edit, params: { conference_id: conference, id: ticket } }

      it 'assigns ticket variable via cancancan' do
        expect(assigns(:ticket)).to eq ticket
      end

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end
    end

    describe 'GET #new' do
      before { get :new, params: { conference_id: conference } }

      it 'assigns ticket variable' do
        expect(assigns(:ticket)).to be_instance_of(Ticket)
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end
    end

    describe 'POST #create' do
      context 'saves successfuly' do
        before(:each, run: true) do
          post :create, params: { conference_id: conference, ticket: attributes_for(:ticket) }
        end

        let!(:ticket_count) { conference.tickets.count }

        it 'redirects to index path', run: true do
          expect(response).to redirect_to(
            admin_conference_tickets_path(conference_id: conference)
          )
        end

        it 'shows success message in flash notice', run: true do
          expect(flash[:notice]).to match('Ticket successfully created.')
        end

        it 'creates new ticket' do
          expect do
            post :create, params: {
                ticket: attributes_for(:ticket),
                conference_id: conference
            }
          end.to change{ conference.tickets.count }.from(ticket_count).to(ticket_count + 1)
        end
      end

      context 'save fails' do
        before do
          allow_any_instance_of(Ticket).to receive(:save).and_return(false)
          post :create, params: { conference_id: conference, ticket: attributes_for(:ticket) }
        end

        let!(:ticket_count) { conference.tickets.count }

        it 'renders new template' do
          expect(response).to render_template('new')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Creating Ticket failed: #{ticket.errors.full_messages.join('. ')}.")
        end

        it 'does not create new ticket' do
          expect(conference.tickets.count).to eq ticket_count
        end
      end
    end

    describe 'PATCH #update' do
      context 'updates successfully' do
        before do
          patch :update, params: {
            conference_id: conference, id: ticket,
            ticket: attributes_for(:ticket, title: new_title)
          }
        end

        it 'redirects to index path' do
          expect(response).to redirect_to(
            admin_conference_tickets_path(conference_id: conference)
          )
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Ticket successfully updated.')
        end

        it 'updates the ticket' do
          ticket.reload
          expect(ticket.title).to eq(new_title)
        end
      end

      context 'update fails' do
        before do
          allow_any_instance_of(Ticket).to receive(:save).and_return(false)
          patch :update, params: {
            conference_id: conference, id: ticket,
            ticket: attributes_for(:ticket, title: new_title)
          }
        end

        it 'renders edit template' do
          expect(response).to render_template('edit')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Ticket update failed: #{ticket.errors.full_messages.join('. ')}.")
        end

        it 'does not update ticket' do
          ticket.reload
          expect(ticket.title).not_to eq(new_title)
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'deletes successfully' do
        before(:each, run: true) do
          delete :destroy, params: { conference_id: conference, id: ticket }
        end

        let!(:ticket_count) { conference.tickets.count }

        it 'redirects to index path', run: true do
          expect(response).to redirect_to(
            admin_conference_tickets_path(conference_id: conference)
          )
        end

        it 'shows success message in flash notice', run: true do
          expect(flash[:notice]).to match('Ticket successfully deleted.')
        end

        it 'deletes the ticket' do
          expect do
            delete :destroy, params: { conference_id: conference, id: ticket }
          end.to change{ conference.tickets.count }.from(ticket_count).to(ticket_count - 1)
        end
      end

      context 'delete fails' do
        let!(:ticket_count) { conference.tickets.count }

        before do
          allow_any_instance_of(Ticket).to receive(:destroy).and_return(false)
          delete :destroy, params: { conference_id: conference, id: ticket }
        end

        it 'redirects to index path' do
          expect(response).to redirect_to(
            admin_conference_tickets_path(conference_id: conference)
          )
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match("Deleting ticket failed! #{ticket.errors.full_messages.join('. ')}.")
        end

        it 'does not delete ticket' do
          expect(conference.tickets.count).to eq(ticket_count)
        end
      end
    end

    describe 'POST #give' do
      context 'grants a ticket purchase to a user' do
        let!(:purchase_count) { admin.ticket_purchases.count }

        before do
          post :give, params: {
            conference_id: conference, id: ticket,
            ticket_purchase: { user_id: admin.id }
          }
        end

        it 'redirects to ticket' do
          expect(response).to redirect_to(
            admin_conference_ticket_path(conference_id: conference, id: ticket)
          )
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match(
            "#{admin.name} was given a #{ticket.title} ticket."
          )
        end

        it 'creates a ticket purchase' do
          expect(admin.ticket_purchases.count).to eq(purchase_count + 1)
          expect(admin.ticket_purchases.last.ticket).to eq(ticket)
        end
      end

      context 'giving fails' do
        before do
          allow_any_instance_of(TicketPurchase).to receive(:save).and_return(false)
          post :give, params: {
            conference_id: conference, id: ticket,
            ticket_purchase: { user_id: admin.id }
          }
        end

        let(:purchase_count) { admin.ticket_purchases.count }

        it 'redirects to ticket' do
          expect(response).to redirect_to(
            admin_conference_ticket_path(conference_id: conference, id: ticket)
          )
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match(
             "Unable to give #{admin.name} a #{ticket.title} ticket: "
           )
        end

        it 'does not create a ticket purchase' do
          expect(admin.ticket_purchases.count).to eq(purchase_count)
        end
      end
    end
  end
end
