require 'spec_helper'

describe ConferenceRegistrationsController, type: :controller do
  let(:conference) { create(:conference) }
  let(:user) { create(:user) }

  context 'user is signed in' do
    before { sign_in(user) }

    describe 'GET #new' do
      context 'registration period open' do
        before do
          @registration_period = create(:registration_period, conference: conference)
        end

        context 'user registered' do
          before do
            @registration = create(:registration, conference: conference, user: user)
            get :new, conference_id: conference.short_title
          end

          it 'redirects to edit conference registration' do
            expect(response).to redirect_to edit_conference_conference_registration_path(conference.short_title)
          end
        end

        context 'user not registered' do
          before do
            get :new, conference_id: conference.short_title
          end

          it 'user variable exists' do
            expect(assigns(:user)).not_to be_nil
          end

          it 'renders the new template' do
            expect(response).to render_template('new')
          end
        end
      end

      context 'registration period not open' do
        before do
          get :new, conference_id: conference.short_title
        end

        it 'redirects to root path' do
          expect(response).to redirect_to root_path
        end

        it 'shows flash alert telling user they are unable to register' do
          expect(flash[:alert]).to eq "Sorry, you can not register for #{conference.title}. Registration limit exceeded or the registration is not open."
        end
      end
    end

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

        it 'does not assign price of purchased tickets to total_price and purchased tickets to tickets without payment' do
          expect(assigns(:total_price)).to eq Money.new(0, 'USD')
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

  context 'user is not signed in' do
    describe 'GET #new' do
      context 'registration period open' do
        before do
          @registration_period = create(:registration_period, conference: conference)
        end

        context 'OSEM_ICHAIN_ENABLED is true' do
          before do
            stub_const('ENV', ENV.to_hash.merge('OSEM_ICHAIN_ENABLED' => 'true'))
            get :new, conference_id: conference.short_title
          end

          it 'redirects to root' do
            expect(response).to redirect_to new_user_session_path
          end

          it 'shows flash alert telling user they cannot register and they need to sign in' do
            expect(flash[:alert]).to eq 'You need to sign in or sign up before continuing.'
          end
        end

        context 'OSEM_ICHAIN_ENABLED is false' do
          before do
            stub_const('ENV', ENV.to_hash.merge('OSEM_ICHAIN_ENABLED' => 'false'))
            get :new, conference_id: conference.short_title
          end

          it 'user variable exists' do
            expect(assigns(:user)).not_to be_nil
          end

          it 'renders the new template' do
            expect(response).to render_template('new')
          end
        end
      end

      context 'registration period not open' do
        context 'OSEM_ICHAIN_ENABLED is true' do
          before do
            stub_const('ENV', ENV.to_hash.merge('OSEM_ICHAIN_ENABLED' => 'true'))
            get :new, conference_id: conference.short_title
          end

          it 'redirects to root' do
            expect(response).to redirect_to new_user_session_path
          end

          it 'shows flash alert telling user they need to sign in' do
            expect(flash[:alert]).to eq 'You need to sign in or sign up before continuing.'
          end
        end

        context 'OSEM_ICHAIN_ENABLED is false' do
          before do
            stub_const('ENV', ENV.to_hash.merge('OSEM_ICHAIN_ENABLED' => 'false'))
            get :new, conference_id: conference.short_title
          end

          it 'redirects to root path' do
            expect(response).to redirect_to root_path
          end

          it 'shows flash alert telling user they cannot register' do
            expect(flash[:alert]).to eq "Sorry, you can not register for #{conference.title}. Registration limit exceeded or the registration is not open. Maybe you need to sign in?"
          end
        end
      end
    end
  end

end
