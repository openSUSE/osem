require 'spec_helper'

describe ConferenceRegistrationsController, type: :controller do
  let(:conference) { create(:conference) }
  let(:user) { create(:user) }

  context 'user is signed in' do
    before { sign_in(user) }

    describe 'GET #show' do
      before do
        @registration = create(:registration, conference: conference, user: user)
        @event_with_registration = create(:event, program: conference.program, require_registration: true, max_attendees: 5, state: 'confirmed')
        @event_without_registration = create(:event, program: conference.program, require_registration: true, max_attendees: 5, state: 'confirmed')
        @registration.events << @event_with_registration
      end

      context 'successful request' do
        before do
          get :show, conference_id: conference.short_title

        end

        it 'assigns variables' do
          expect(assigns(:conference)).to eq conference
          expect(assigns(:registration)).to eq @registration
        end

        it 'renders the show template' do
          expect(response).to render_template('show')
        end
      end

      context 'user has purchased a ticket' do
        before do
          @ticket = create(:ticket, conference: conference)
          @purchased_ticket = create(:ticket_purchase, conference: conference,
                                                       user: user,
                                                       ticket: @ticket)
          get :show, conference_id: conference.short_title
        end

        it 'assigns price of purchased tickets to total_price and purchased tickets to tickets' do
          expect(assigns(:total_price)).to eq Money.new(10000, 'USD')
          expect(assigns(:tickets)).to match_array [@purchased_ticket]
        end
      end

      context 'user has not purchased any ticket' do
        before do
          get :show, conference_id: conference.short_title
        end

        it 'assigns 0 dollars to total_price and empty array to tickets variables' do
          expect(assigns(:total_price)).to eq Money.new(0, 'USD')
          expect(assigns(:tickets)).to match_array []
        end
      end
    end

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
          expect(response).to redirect_to conference_conference_registration_path(conference.short_title)
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
          expect(flash[:error]).to match "Could not update your registration for #{conference.title}: #{@registration.errors.full_messages.join('. ')}."
        end

        it 'does not update the registration' do
          @registration.reload
          expect(@registration.arrival).to eq Date.new(2014, 04, 25)
        end
      end
    end

    describe 'DELETE #destroy' do
      before do
        @registration = create(:registration, conference: conference, user: user)
      end

      context 'deletes successfully' do
        before(:each, run: true) do
          delete :destroy, conference_id: conference.short_title
        end

        it 'redirects to root path', run: true do
          expect(response).to redirect_to root_path
        end

        it 'shows success message in flash notice', run: true do
          expect(flash[:notice]).to match("You are not registered for #{conference.title} anymore!")
        end

        it 'deletes the registration' do
          expect do
            delete :destroy, conference_id: conference.short_title
          end.to change{ Registration.count }.from(1).to(0)
        end
      end

      context 'delete fails' do
        before do
          allow_any_instance_of(Registration).to receive(:destroy).and_return(false)
          delete :destroy, conference_id: conference.short_title
        end

        it 'redirects to registration show path' do
          expect(response).to redirect_to conference_conference_registration_path(conference.short_title)
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match "Could not delete your registration for #{conference.title}: #{@registration.errors.full_messages.join('. ')}."
        end

        it 'does not delete the registration' do
          expect(assigns(:registration)).to eq @registration
        end
      end
    end
  end
end
