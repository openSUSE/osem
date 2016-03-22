require 'spec_helper'

describe ConferenceRegistrationsController, type: :controller do
  let(:conference) { create(:conference) }
  let(:user) { create(:user) }

  context 'user is signed in' do
    before { sign_in(user) }

    describe 'GET #edit' do
      before do
        @registration = create(:registration, conference: conference, user: user)
        get :edit, conference_id: conference.short_title
      end

      it 'assigns conference and registration variable' do
        expect(assigns(:conference)).to eq conference
        expect(assigns(:registration)).to eq @registration
      end

      it 'renders the edit template' do
        expect(response).to render_template('edit')
      end
    end

    describe 'PATCH #update' do
      before do
        @registration = create(:registration,
                               conference: conference,
                               user: user,
                               arrival: Date.new(2014, 04, 25))
      end

      context 'updates successfully' do
        before do
          patch :update, registration: attributes_for(:registration, arrival: Date.new(2014, 04, 29)),
                         conference_id: conference.short_title
        end

        it 'redirects to registration show path' do
          expect(response).to redirect_to conference_conference_registrations_path(conference.short_title)
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Registration was successfully updated.')
        end

        it 'updates the registration' do
          @registration.reload
          expect(@registration.arrival).to eq Date.new(2014, 04, 29)
        end
      end

      context 'update fails' do
        before do
          allow_any_instance_of(Registration).to receive(:update_attributes).and_return(false)
          patch :update, registration: attributes_for(:registration, arrival: Date.new(2014, 04, 27)),
                         conference_id: conference.short_title
        end

        it 'renders edit template' do
          expect(response).to render_template('edit')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match "Could not update your registration for The dog and pony show: #{@registration.errors.full_messages.join('. ')}."
        end

        it 'does not update the registration' do
          @registration.reload
          expect(@registration.arrival).to eq Date.new(2014, 04, 25)
        end
      end
    end
  end
end
