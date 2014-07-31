require 'spec_helper'

describe Admin::ConferenceContactsController do

  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  let(:conference) { create(:conference) }
  let(:admin) { create(:admin) }
  let(:organizer) { create(:organizer) }
  let(:participant) { create(:participant) }

  shared_examples 'access as administration or organizer' do

    before(:each) do
      request.env['HTTP_REFERER'] = 'http://test.host'
    end

    describe 'PATCH #update' do

      context 'valid attributes' do

        it 'locates the requested conference' do
          patch :update, conference_id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con')
          expect(assigns(:conference)).to eq(conference)
        end

        it 'changes conference attributes' do
          patch :update, conference_id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con',
                             short_title: 'ExCon')

          conference.reload
          expect(conference.title).to eq('Example Con')
          expect(conference.short_title).to eq('ExCon')
        end

        it 'redirects to the updated conference' do
          session[:return_to] = request.env['HTTP_REFERER'] +
              edit_admin_conference_conference_basics_path(conference.short_title)

          patch :update, conference_id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con')
          conference.reload
          expect(response).to redirect_to edit_admin_conference_conference_basics_path(
                                              conference.short_title)
        end

        it 'redirects to conference show if no :return_to is specified' do

          patch :update, conference_id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con')
          conference.reload
          expect(response).to redirect_to admin_conference_path(
                                              conference.short_title)
        end

        it 'sends email notification on conference date update' do
          mailer = double
          allow(mailer).to receive(:deliver)
          conference.email_settings = create(:email_settings)
          patch :update, conference_id: conference.short_title, conference:
              attributes_for(:conference, start_date: Date.today + 2.days, end_date: Date.today + 4.days)
          conference.reload
          allow(Mailbot).to receive(:conference_date_update_mail).and_return(mailer)
        end

        it 'sends email notification on conference registration date update' do
          mailer = double
          allow(mailer).to receive(:deliver)
          conference.email_settings = create(:email_settings)
          patch :update, conference_id: conference.short_title, conference:
              attributes_for(:conference, registration_start_date: Date.today + 2.days, registration_end_date: Date.today + 4.days)
          conference.reload
          allow(Mailbot).to receive(:conference_registration_date_update_mail).and_return(mailer)
        end
      end

      context 'invalid attributes' do
        it 'does not change conference attributes' do
          patch :update, conference_id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con',
                             short_title: nil)

          conference.reload
          expect(flash[:alert]).
              to eq("Updating conference failed. Short title can't be blank.")
          expect(conference.title).to eq('The dog and pony show')
          expect(conference.short_title).to eq("#{conference.short_title}")
        end

        it 're-renders the #show template' do
          request.env['HTTP_REFERER'] = request.env['HTTP_REFERER'] +
              edit_admin_conference_conference_basics_path(conference.short_title)

          patch :update, conference_id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con',
                             short_title: nil)

          expect(flash[:alert]).
              to eq("Updating conference failed. Short title can't be blank.")
          expect(response).to redirect_to edit_admin_conference_conference_basics_path(
                                              conference.short_title)
        end
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested conference to conference' do
        get :edit, conference_id: conference.short_title
        expect(assigns(:conference)).to eq conference
      end

      it 'renders the show template' do
        get :edit, conference_id: conference.short_title
        expect(response).to render_template :edit
      end
    end

  end

  describe 'administrator access' do

    before do
      sign_in(admin)
    end

    it_behaves_like 'access as administration or organizer'

  end

  describe 'organizer access' do

    before(:each) do
      sign_in(organizer)
    end

    it_behaves_like 'access as administration or organizer'

  end

  shared_examples 'access as participant or guest' do |success_path|
    describe 'GET #edit' do
      it 'requires admin privileges' do
        get :edit, conference_id: conference.short_title
        expect(response).to redirect_to(send(success_path))
      end
    end

    describe 'PATCH #update' do
      it 'requires admin privileges' do
        patch :update, conference_id: conference.short_title,
              conference: attributes_for(:conference,
                                         short_title: 'ExCon')
        expect(response).to redirect_to(send(success_path))
      end
    end
  end

  describe 'participant access' do
    before(:each) do
      sign_in(participant)
    end

    it_behaves_like 'access as participant or guest', :root_path

  end

  describe 'guest access' do

    it_behaves_like 'access as participant or guest', :new_user_session_path

  end
end