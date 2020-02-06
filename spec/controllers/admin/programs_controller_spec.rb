# frozen_string_literal: true

require 'spec_helper'

describe Admin::ProgramsController, type: :controller do

  # It is necessary to use bang version of let to build roles before user
  let(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  context 'not logged in user' do
    describe 'GET #show' do
      it 'does not render admin/programs#show' do
        get :show, params: { conference_id: conference.short_title }
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  context 'logged in as admin, organizer or cfp' do
    before :each do
      sign_in(organizer)
    end

    describe 'PATCH #update' do
      it 'redirects to admin/programs#index' do
        patch :update, params: { conference_id: conference.short_title, program: attributes_for(:program) }
        conference.program.reload
        expect(response).to redirect_to admin_conference_program_path(conference.short_title)
      end
    end
  end
end
