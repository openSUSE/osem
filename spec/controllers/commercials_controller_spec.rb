# frozen_string_literal: true

require 'spec_helper'

describe CommercialsController do
  let(:conference) { create(:conference) }
  let(:event) { create(:event, program: conference.program) }
  let(:commercial_params) do
    {
      conference_id: conference.short_title,
      proposal_id:   event.id,
      commercial:    { url: 'https://www.youtube.com/watch?v=M9bq_alk-sw' }
    }
  end

  describe 'POST #create' do
    context 'when user is organizer of conference' do
      let(:user) { create(:organizer, resource: conference) }

      before do
        sign_in user
      end

      it 'creates a commercial for the event' do
        expect do
          post :create, params: commercial_params
        end.to change(Commercial, :count).by(1)
      end

      it 'redirects to proposal edit page' do
        post :create, params: commercial_params

        expect(response).to redirect_to(edit_conference_program_proposal_path(conference.short_title, event.id, anchor: 'commercials-content'))
        expect(flash[:notice]).to eq('Commercial was successfully created.')
      end
    end

    context 'when user is on cfp team of conference' do
      let(:user) { create(:cfp_user, resource: conference) }

      before do
        sign_in user
      end

      it 'creates a commercial for the event' do
        expect do
          post :create, params: commercial_params
        end.to change(Commercial, :count).by(1)
      end

      it 'redirects to proposal edit page' do
        post :create, params: commercial_params

        expect(response).to redirect_to(edit_conference_program_proposal_path(conference.short_title, event.id, anchor: 'commercials-content'))
        expect(flash[:notice]).to eq('Commercial was successfully created.')
      end
    end
  end
end
