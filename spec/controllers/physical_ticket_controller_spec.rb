# frozen_string_literal: true

require 'spec_helper'

describe PhysicalTicketsController do
  let(:conference) { create(:conference) }
  let(:user) { create(:user) }
  let(:paid_ticket_purchase) { create(:ticket_purchase, conference: conference, user: user) }
  let(:physical_ticket) { create(:physical_ticket, ticket_purchase: paid_ticket_purchase) }

  describe 'GET #show' do
    before :each do
      sign_in user
      get :show, params: { id: physical_ticket.token, conference_id: conference.short_title }
    end

    it 'assigns ticket_layout' do
      ticket_layout = conference.ticket_layout.to_sym
      expect(assigns(:ticket_layout)).to eq ticket_layout
    end
  end
end
