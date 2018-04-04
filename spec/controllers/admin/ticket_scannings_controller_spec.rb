# frozen_string_literal: true

require 'spec_helper'

describe Admin::TicketScanningsController do
  let(:admin) { create(:admin) }
  let(:conference) { create(:conference) }
  let(:user) { create(:user) }
  let!(:registration) { create(:registration, conference: conference, user: user) }
  let(:registration_ticket) { create(:registration_ticket, conference: conference) }
  let(:paid_ticket_purchase) { create(:ticket_purchase, conference: conference, user: user, ticket: registration_ticket, quantity: 1) }
  let(:physical_ticket) { create(:physical_ticket, ticket_purchase: paid_ticket_purchase) }

  context 'logged in as user with no role' do
    before :each do
      sign_in user
    end
    describe 'POST #create' do
      it 'does not create new ticket scanning' do
        expected = expect do
          post :create, params: { physical_ticket_id: physical_ticket.token }
        end
        expected.to_not change(TicketScanning, :count)
      end

      it 'redirects to root' do
        post :create, params: { physical_ticket_id: physical_ticket.token }
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context 'logged in as admin' do
    before :each do
      sign_in admin
    end
    describe 'POST #create' do
      context 'with valid physical_ticket' do
        it 'creates new ticket scanning' do
          expected = expect do
            post :create, params: { physical_ticket_id: physical_ticket.token }
          end
          expected.to change { TicketScanning.count }.by(1)
        end

        it 'redirects to index' do
          post :create, params: { physical_ticket_id: physical_ticket.token }
          expect(flash[:notice]).to eq("Ticket with token #{physical_ticket.token} successfully scanned.")
          expect(response).to redirect_to(conferences_path)
        end
      end

      context 'with Invalid physical_ticket' do
        it 'raises exception' do
          expected = expect do
            post :create, params: { physical_ticket_id: 'XXXX' }
          end
          expected.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
