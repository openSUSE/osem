require 'spec_helper'

describe Admin::SchedulesController do
  let(:conference) { create(:conference) }
  let(:schedule) { create(:schedule, program: conference.program)}
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let(:organizer) { create(:user, role_ids: organizer_role.id) }

  context 'logged in as an organizer' do
    before :each do
      sign_in(organizer)
      schedule
    end

    describe 'GET #index' do
      it 'renders the index template' do
        get :index, conference_id: conference.short_title
        expect(response).to render_template :index
      end
    end

    describe 'POST #create' do
      it 'saves the schedule to the database' do
        expected = expect do
          post :create, conference_id: conference.short_title
        end
        expected.to change { Schedule.count }.by 1
      end

      it 'redirects to schedules#show' do
        post :create, conference_id: conference.short_title

        expect(response).to redirect_to admin_conference_schedule_path(
                                        conference.short_title, assigns[:schedule])
      end
    end

    describe 'GET #show' do
      it 'assigns the requested schedule to schedule' do
        get :show, id: schedule.id, conference_id: conference.short_title
        expect(assigns(:schedule)).to eq schedule
      end

      it 'renders the show template' do
        get :show, id: schedule.id, conference_id: conference.short_title
        expect(response).to render_template :show
      end
    end

    describe 'DELETE #destroy' do
      it 'deletes the schedule' do
        expected = expect do
          delete :destroy, id: schedule.id, conference_id: conference.short_title
        end
        expected.to change { Schedule.count }.by(-1)
      end
      it 'redirects to schedules#index' do
        delete :destroy, id: schedule.id, conference_id: conference.short_title
        expect(response).to redirect_to admin_conference_schedules_path(conference.short_title)
      end
    end
  end
end
