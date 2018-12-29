# frozen_string_literal: true

require 'spec_helper'

describe ConferenceRegistrationsController, type: :controller do
  let(:conference) { create(:conference, title: 'My Conference', short_title: 'myconf') }
  let(:user) { create(:user) }
  let(:not_registered_user) { create(:user) }
  let(:registered_user) { create(:user) }
  let!(:registration) { create(:registration, conference: conference, user: registered_user, created_at: 1.day.ago) }

  shared_examples 'access #new action' do |user, ichain, path, message|
    before :each do
      sign_in send(user) if user
      stub_const('ENV', ENV.to_hash.merge('OSEM_ICHAIN_ENABLED' => ichain))
      get :new, params: { conference_id: conference.short_title }
    end

    it 'redirects' do
      expect(response).to redirect_to path
    end

    it 'shows flash alert' do
      expect(flash[:alert]).to eq message
    end
  end

  shared_examples 'can access #new action' do |user, ichain|
    before :each do
      sign_in send(user) if user
      stub_const('ENV', ENV.to_hash.merge('OSEM_ICHAIN_ENABLED' => ichain))
      get :new, params: { conference_id: conference.short_title }
    end

    it 'user variable exists' do
      expect(assigns(:user)).not_to be_nil
    end

    it 'renders the new template' do
      expect(response).to render_template('new')
    end
  end

  context 'user is signed in' do
    before :each do
      sign_in user
    end

    describe 'GET #new' do
      let(:not_registered_confirmed_speaker) { create(:user) }
      let(:registered_confirmed_speaker) { create(:user) }
      let!(:speaker_registration) { create(:registration, conference: conference, user: registered_confirmed_speaker, created_at: 1.day.ago) }
      let!(:confirmed_event) { create(:event, program: conference.program, speakers: [not_registered_confirmed_speaker, registered_confirmed_speaker], state: 'confirmed') }

      context 'registration period open' do
        before :each do
          create(:registration_period, conference: conference, start_date: 3.days.ago, end_date: 1.day.from_now)
        end

        context 'registration limit not exceeded' do
          before :each do
            conference.registration_limit = 0
            conference.save!
          end

          context 'OSEM_ICHAIN_ENABLED true, user registered' do
            it_behaves_like 'access #new action', :registered_user, 'true', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED true, user not registered' do
            it_behaves_like 'can access #new action', :not_registered_user, 'true'
          end

          context 'OSEM_ICHAIN_ENABLED true, user registered, confirmed speaker' do
            it_behaves_like 'access #new action', :registered_confirmed_speaker, 'true', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED true, user not registered, confirmed speaker' do
            it_behaves_like 'can access #new action', :not_registered_confirmed_speaker, 'true'
          end

          context 'OSEM_ICHAIN_ENABLED false, user registered' do
            it_behaves_like 'access #new action', :registered_user, 'false', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED false, user not registered' do
            it_behaves_like 'can access #new action', :not_registered_user, 'false'
          end

          context 'OSEM_ICHAIN_ENABLED false, user registered, confirmed speaker' do
            it_behaves_like 'access #new action', :registered_confirmed_speaker, 'false', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED false, user not registered, confirmed speaker' do
            it_behaves_like 'can access #new action', :not_registered_confirmed_speaker, 'false'
          end
        end

        context 'registration limit exceeded' do
          before :each do
            conference.registration_limit = 1
            conference.save!
          end

          context 'OSEM_ICHAIN_ENABLED true, user registered' do
            it_behaves_like 'access #new action', :registered_user, 'true', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED true, user not registered' do
            it_behaves_like 'access #new action', :not_registered_user, 'true', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end

          context 'OSEM_ICHAIN_ENABLED true, user registered, confirmed speaker' do
            it_behaves_like 'access #new action', :registered_confirmed_speaker, 'true', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED true, user not registered, confirmed speaker' do
            it_behaves_like 'can access #new action', :not_registered_confirmed_speaker, 'true'
          end

          context 'OSEM_ICHAIN_ENABLED false, user registered' do
            it_behaves_like 'access #new action', :registered_user, 'false', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED false, user not registered' do
            it_behaves_like 'access #new action', :not_registered_user, 'false', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end

          context 'OSEM_ICHAIN_ENABLED false, user registered, confirmed speaker' do
            it_behaves_like 'access #new action', :registered_confirmed_speaker, 'false', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED false, user not registered, confirmed speaker' do
            it_behaves_like 'can access #new action', :not_registered_confirmed_speaker, 'false'
          end
        end
      end

      context 'registration period not open' do
        before :each do
          create(:registration_period, conference: conference, start_date: 3.days.ago, end_date: 1.day.ago)
        end

        context 'registration limit not exceeded' do
          before :each do
            conference.registration_limit = 0
            conference.save!
          end

          context 'OSEM_ICHAIN_ENABLED true, user registered' do
            it_behaves_like 'access #new action', :registered_user, 'true', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED true, user not registered' do
            it_behaves_like 'access #new action', :not_registered_user, 'true', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end

          context 'OSEM_ICHAIN_ENABLED true, user registered, confirmed speaker' do
            it_behaves_like 'access #new action', :registered_confirmed_speaker, 'true', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED true, user not registered, confirmed speaker' do
            it_behaves_like 'can access #new action', :not_registered_confirmed_speaker, 'true'
          end

          context 'OSEM_ICHAIN_ENABLED false, user registered' do
            it_behaves_like 'access #new action', :registered_user, 'false', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED false, user not registered' do
            it_behaves_like 'access #new action', :not_registered_user, 'false', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end

          context 'OSEM_ICHAIN_ENABLED false, user registered, confirmed speaker' do
            it_behaves_like 'access #new action', :registered_confirmed_speaker, 'false', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED false, user not registered, confirmed speaker' do
            it_behaves_like 'can access #new action', :not_registered_confirmed_speaker, 'false'
          end
        end

        context 'registration limit exceeded' do
          before do
            conference.registration_limit = 1
            conference.save!
          end

          context 'OSEM_ICHAIN_ENABLED true, user registered' do
            it_behaves_like 'access #new action', :registered_user, 'true', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED true, user not registered' do
            it_behaves_like 'access #new action', :not_registered_user, 'true', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end

          context 'OSEM_ICHAIN_ENABLED true, user registered, confirmed speaker' do
            it_behaves_like 'access #new action', :registered_confirmed_speaker, 'true', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED true, user not registered, confirmed speaker' do
            it_behaves_like 'can access #new action', :not_registered_confirmed_speaker, 'true'
          end

          context 'OSEM_ICHAIN_ENABLED false, user registered' do
            it_behaves_like 'access #new action', :registered_user, 'false', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED false, user not registered' do
            it_behaves_like 'access #new action', :not_registered_user, 'false', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end

          context 'OSEM_ICHAIN_ENABLED false, user registered, confirmed speaker' do
            it_behaves_like 'access #new action', :registered_confirmed_speaker, 'false', '/conferences/myconf/register/edit', nil
          end

          context 'OSEM_ICHAIN_ENABLED false, user not registered, confirmed speaker' do
            it_behaves_like 'can access #new action', :not_registered_confirmed_speaker, 'false'
          end
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
          get :show, params: { conference_id: conference.short_title }
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
                                                       user:       user,
                                                       ticket:     @ticket)
          get :show, params: { conference_id: conference.short_title }
        end

        it 'does not assign price of purchased tickets to total_price and purchased tickets to tickets without payment' do
          expect(assigns(:total_price)).to eq 0
        end
      end

      context 'user has not purchased any ticket' do
        before do
          get :show, params: { conference_id: conference.short_title }
        end

        it 'assigns 0 dollars to total_price and empty array to tickets variables' do
          expect(assigns(:total_price)).to eq 0
          expect(assigns(:tickets)).to match_array []
        end
      end
    end

    describe 'GET #edit' do
      before do
        @registration = create(:registration, conference: conference, user: user)
        get :edit, params: { conference_id: conference.short_title }
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
                               user:       user)
      end

      context 'updates successfully' do
        before do
          patch :update, params: {
            registration:  attributes_for(:registration, volunteer: true),
            conference_id: conference.short_title
          }
        end

        it 'redirects to registration show path' do
          expect(response).to redirect_to conference_conference_registration_path(conference.short_title)
        end

        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('Registration was successfully updated.')
        end

        it 'updates the registration' do
          expect{ @registration.reload }.to change(@registration, :updated_at)
        end
      end

      context 'update fails' do
        before do
          allow_any_instance_of(Registration).to receive(:update_attributes).and_return(false)
          patch :update, params: {
            registration:  attributes_for(:registration, volunteer: true),
            conference_id: conference.short_title
          }
        end

        it 'renders edit template' do
          expect(response).to render_template('edit')
        end

        it 'shows error in flash message' do
          expect(flash[:error]).to match "Could not update your registration for #{conference.title}: #{@registration.errors.full_messages.join('. ')}."
        end

        it 'does not update the registration' do
          @registration.reload
          expect { @registration.reload }.not_to change(@registration, :updated_at)
        end
      end
    end

    describe 'DELETE #destroy' do
      before do
        @registration = create(:registration, conference: conference, user: user)
      end

      context 'deletes successfully' do
        before(:each, run: true) do
          delete :destroy, params: { conference_id: conference.short_title }
        end

        it 'redirects to root path', run: true do
          expect(response).to redirect_to root_path
        end

        it 'shows success message in flash notice', run: true do
          expect(flash[:notice]).to match("You are not registered for #{conference.title} anymore!")
        end

        it 'deletes the registration' do
          expect do
            delete :destroy, params: { conference_id: conference.short_title }
          end.to change{ Registration.count }.from(2).to(1)
        end
      end

      context 'delete fails' do
        before do
          allow_any_instance_of(Registration).to receive(:destroy).and_return(false)
          delete :destroy, params: { conference_id: conference.short_title }
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
        before :each do
          create(:registration_period, conference: conference, start_date: 3.days.ago, end_date: 1.day.from_now)
        end

        context 'registration limit not exceeded' do
          before :each do
            conference.registration_limit = 0
            conference.save!
          end

          context 'OSEM_ICHAIN_ENABLED is true' do
            it_behaves_like 'access #new action', nil, 'true', '/', 'You are not authorized to access this page. Maybe you need to sign in?'
          end

          context 'OSEM_ICHAIN_ENABLED is false' do
            it_behaves_like 'can access #new action', nil, 'false'
          end
        end

        context 'registration limit exceeded' do
          before :each do
            conference.registration_limit = 1
            conference.save!
          end

          context 'OSEM_ICHAIN_ENABLED is true' do
            it_behaves_like 'access #new action', nil, 'true', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end

          context 'OSEM_ICHAIN_ENABLED is false' do
            it_behaves_like 'access #new action', nil, 'false', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end
        end
      end

      context 'registration period not open' do
        before :each do
          create(:registration_period, conference: conference, start_date: 3.days.ago, end_date: 1.day.ago)
        end

        context 'registration limit not exceeded' do
          before :each do
            conference.registration_limit = 0
            conference.save!
          end

          context 'OSEM_ICHAIN_ENABLED is true' do
            it_behaves_like 'access #new action', nil, 'true', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end

          context 'OSEM_ICHAIN_ENABLED is false' do
            it_behaves_like 'access #new action', nil, 'false', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end
        end

        context 'registration limit exceeded' do
          before :each do
            conference.registration_limit = 1
            conference.save!
          end

          context 'OSEM_ICHAIN_ENABLED is true' do
            it_behaves_like 'access #new action', nil, 'true', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end

          context 'OSEM_ICHAIN_ENABLED is false' do
            it_behaves_like 'access #new action', nil, 'false', '/', 'Sorry, you can not register for My Conference. Registration limit exceeded or the registration is not open.'
          end
        end
      end
    end
  end
end
