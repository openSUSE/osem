require 'spec_helper'

describe ConferenceRegistrationsController, type: :controller do
  let!(:first_user) { create(:user) }
  let(:conference) { create(:conference) }
  let(:conference_with_open_registration) { create(:conference) }
  let!(:open_registration_period) { create(:registration_period, conference: conference_with_open_registration, start_date: Date.current - 6.days) }
  let(:user) { create(:user) }

  context 'user is not signed in' do
    describe 'GET #new' do
      context 'ichain is disabled' do
        before do
          get :new, conference_id: conference_with_open_registration.short_title
        end

        it 'assigns conference, registration and user variable' do
          expect(assigns(:conference)).to eq conference_with_open_registration
          expect(assigns(:registration)).to be_instance_of Registration
          expect(assigns(:user)).to be_instance_of User
        end

        it 'renders the new template' do
          expect(response).to render_template('new')
        end
      end

      context 'ichain is enabled' do
        before do
          CONFIG['authentication']['ichain']['enabled'] = true
          get :new, conference_id: conference_with_open_registration.short_title
        end

        after { CONFIG['authentication']['ichain']['enabled'] = false }

        it 'redirects to root path' do
          expect(response).to redirect_to root_path
        end

        it 'shows error in flash message' do
          expect(flash[:alert]).to match 'You are not authorized to access this page. Maybe you need to sign in?'
        end
      end
    end

    describe 'POST #create' do
      before do
        post :create, user: attributes_for(:user),
                      registration: attributes_for(:registration),
                      conference_id: conference_with_open_registration.short_title
      end

      it 'assigns user variable' do
        expect(assigns(:user)).not_to be_nil
      end

      it 'signs in registration user' do
        expect(controller.current_user).not_to be_nil
      end

      it 'shows success message in flash notice' do
        expect(flash[:notice]).to match('You are now registered and will be receiving E-Mail notifications.')
      end

      it 'redirects to registration show path' do
        expect(response).to redirect_to conference_conference_registrations_path(conference_with_open_registration.short_title)
      end

      it 'creates a new registration' do
        expect(Registration.count).to eq 1
      end
    end
  end

  context 'user is signed in' do
    before { sign_in(user) }

    describe 'GET #new' do
      context 'successful request' do
        before do
          get :new, conference_id: conference_with_open_registration.short_title
        end

        it 'assigns registration and user variables' do
          expect(assigns(:registration)).to be_instance_of(Registration)
          expect(assigns(:user)).to be_instance_of(User)
        end

        it 'renders the new template' do
          expect(response).to render_template('new')
        end
      end

      context 'user is registered to conference' do
        before do
          create(:registration, user: user, conference: conference_with_open_registration)
          get :new, conference_id: conference_with_open_registration.short_title
        end

        it 'redirects to edit registration page' do
          expect(response).to redirect_to edit_conference_conference_registrations_path(conference_with_open_registration.short_title)
        end
      end

      context 'registration limit has reached' do
        before do
          conference_with_open_registration.update_attributes(registration_limit: 1)
          create(:registration, conference: conference_with_open_registration)
          get :new, conference_id: conference_with_open_registration.short_title
        end

        it 'redirects to root path' do
          expect(response).to redirect_to root_path
        end

        it 'shows error in flash message' do
          expect(flash[:alert]).to match "Sorry, registration limit exceeded for #{conference_with_open_registration.title}"
        end
      end
    end

    describe 'GET #show' do
      before do
        @registration = create(:registration, conference: conference_with_open_registration, user: user)
      end

      context 'successful request' do
        before do
          get :show, conference_id: conference_with_open_registration.short_title
        end

        it 'assigns conference, registration and workshops variables' do
          expect(assigns(:conference)).to eq conference_with_open_registration
          expect(assigns(:registration)).to eq @registration
          expect(assigns(:workshops)).to eq @registration.workshops
        end

        it 'renders the show template' do
          expect(response).to render_template('show')
        end
      end

      context 'user has purchased a ticket' do
        before do
          @ticket = create(:ticket, conference: conference_with_open_registration)
          @purchased_ticket = create(:ticket_purchase, conference: conference_with_open_registration,
                                                       user: user,
                                                       ticket: @ticket)
          get :show, conference_id: conference_with_open_registration.short_title
        end

        it 'assigns price of purchased tickets to total_price and purchased tickets to tickets' do
          expect(assigns(:total_price)).to eq Money.new(10000, 'USD')
          expect(assigns(:tickets)).to match_array [@purchased_ticket]
        end
      end

      context 'user has not purchased any ticket' do
        before do
          get :show, conference_id: conference_with_open_registration.short_title
        end

        it 'assigns 0 dollars to total_price and empty array to tickets variables' do
          expect(assigns(:total_price)).to eq Money.new(0, 'USD')
          expect(assigns(:tickets)).to match_array []
        end
      end
    end

    describe 'GET #edit' do
      before do
        @registration = create(:registration, conference: conference_with_open_registration, user: user)
        get :edit, conference_id: conference_with_open_registration.short_title
      end

      it 'assigns conference and registration variable' do
        expect(assigns(:conference)).to eq conference_with_open_registration
        expect(assigns(:registration)).to eq @registration
      end

      it 'renders the edit template' do
        expect(response).to render_template('edit')
      end
    end

    describe 'POST #create' do
      context 'successfully registers' do
        it 'assigns user variable' do
          post :create, registration: attributes_for(:registration),
                        conference_id: conference_with_open_registration.short_title
          expect(assigns(:user)).to eq user
        end

        it 'creates a new registration' do
          expect do
            post :create, registration: attributes_for(:registration),
                          conference_id: conference_with_open_registration.short_title
          end.to change{ Registration.count }.by 1
        end
      end

      context 'tickets are available' do
        before do
          create(:ticket, conference: conference_with_open_registration)
          post :create, registration: attributes_for(:registration),
                        conference_id: conference_with_open_registration.short_title
        end

        it 'redirects to conference tickets path' do
          expect(response).to redirect_to conference_tickets_path(conference_with_open_registration.short_title)
        end
      end

      context 'tickets are not available' do
        before do
          post :create, registration: attributes_for(:registration),
                        conference_id: conference_with_open_registration.short_title
        end

        it 'redirects to registration show path' do
          expect(response).to redirect_to conference_conference_registrations_path(conference_with_open_registration.short_title)
        end
      end

      context 'registration save fails' do
        before do
          allow_any_instance_of(Registration).to receive(:save).and_return(false)
          post :create, registration: attributes_for(:registration),
                        conference_id: conference_with_open_registration.short_title
        end

        it 'renders the new template' do
          expect(response).to render_template('new')
        end

        it 'does not create registration' do
          expect(Registration.count).to eq 0
        end
      end
    end

    describe 'PATCH #update' do
      before do
        @registration = create(:registration,
                               conference: conference_with_open_registration,
                               user: user,
                               arrival: Date.new(2014, 04, 25))
      end

      context 'updates successfully' do
        before do
          patch :update, registration: attributes_for(:registration, arrival: Date.new(2014, 04, 29)),
                         conference_id: conference_with_open_registration.short_title
        end

        it 'redirects to registration show path' do
          expect(response).to redirect_to conference_conference_registrations_path(conference_with_open_registration.short_title)
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
                         conference_id: conference_with_open_registration.short_title
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

    describe 'DELETE #destroy' do
      before do
        @registration = create(:registration, conference: conference_with_open_registration, user: user)
      end

      context 'deletes successfully' do
        before do
          delete :destroy, conference_id: conference_with_open_registration.short_title
        end

        it 'redirects to root path' do
          expect(response).to redirect_to root_path
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('You are not registered for The dog and pony show anymore!')
        end

        it 'deletes the registration' do
          expect(Registration.count).to eq 0
        end
      end

      context 'delete fails' do
        before do
          allow_any_instance_of(Registration).to receive(:destroy).and_return(false)
          delete :destroy, conference_id: conference_with_open_registration.short_title
        end

        it 'redirects to registration show path' do
          expect(response).to redirect_to conference_conference_registrations_path(conference_with_open_registration.short_title)
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match "Could not delete your registration for The dog and pony show: #{@registration.errors.full_messages.join('. ')}."
        end

        it 'does not delete the registration' do
          expect(assigns(:registration)).to eq @registration
        end
      end
    end
  end
end
