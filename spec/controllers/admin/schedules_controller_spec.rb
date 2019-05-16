# frozen_string_literal: true

require 'spec_helper'

describe Admin::SchedulesController do
  let(:conference) { create(:conference) }
  let(:schedule) { create(:schedule, program: conference.program)}
  let!(:organizer) { create(:organizer, resource: conference) }

  context 'logged in as an organizer' do
    before :each do
      sign_in(organizer)
      schedule
    end

    describe 'GET #index' do
      it 'renders the index template' do
        get :index, params: { conference_id: conference.short_title }
        expect(response).to render_template :index
      end
    end

    describe 'POST #create' do
      let(:create_action){ post :create, params: { conference_id: conference.short_title } }

      it 'saves the schedule to the database' do
        expect{ create_action }.to change { Schedule.count }.by 1
      end

      it 'redirects to schedules#show' do
        create_action
        expect(response).to redirect_to admin_conference_schedule_path(
                                        conference.short_title, assigns[:schedule])
      end
    end

    describe 'GET #show' do
      let(:show_action){ get :show, params: { id: schedule.id, conference_id: conference.short_title } }

      it 'assigns the requested schedule to schedule' do
        show_action
        expect(assigns(:schedule)).to eq schedule
      end

      it 'renders the show template' do
        show_action
        expect(response).to render_template :show
      end
    end

    describe 'DELETE #destroy' do
      let(:destroy_action){ delete :destroy, params: { id: schedule.id, conference_id: conference.short_title } }

      it 'deletes the schedule' do
        expect{ destroy_action }.to change { Schedule.count }.by(-1)
      end

      it 'redirects to schedules#index' do
        destroy_action
        expect(response).to redirect_to admin_conference_schedules_path(conference.short_title)
      end
    end
  end
end
