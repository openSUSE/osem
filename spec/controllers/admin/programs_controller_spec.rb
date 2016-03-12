require 'spec_helper'

describe Admin::ProgramsController, type: :controller do

  # It is necessary to use bang version of let to build roles before user
  let(:conference) { create(:conference) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let(:organizer) { create(:user, role_ids: organizer_role.id, last_sign_in_at: Time.now - 1.day) }

  context 'not logged in user' do
    describe 'GET #show' do
      it 'does not render admin/programs#show' do
        get :show, conference_id: conference.short_title
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
        patch :update, conference_id: conference.short_title, program: attributes_for(:program)
        conference.program.reload
        expect(response).to redirect_to admin_conference_program_path(conference.short_title)
      end
    end
  end
end
