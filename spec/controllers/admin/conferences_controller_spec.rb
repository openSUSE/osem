require 'spec_helper'

describe Admin::ConferenceController do

  # It is necessary to use bang version of let to build roles before user
  let(:conference) { create(:conference, end_date: Date.new(2014, 05, 26) + 15) }
  let!(:first_user) { create(:user) }
  let!(:organizer_role) { create(:role, name: 'organizer', resource: conference) }

  let(:organizer) { create(:user, role_ids: organizer_role.id) }
  let(:organizer2) { create(:user, email: 'organizer2@email.osem', role_ids: organizer_role.id) }
  let(:participant) { create(:user) }

  shared_examples 'access as organizer' do

    describe 'PATCH #update' do

      context 'valid attributes' do

        it 'locates the requested conference' do
          patch :update, id: conference.short_title, conference: attributes_for(:conference, title: 'Example Con')
          expect(assigns(:conference)).to eq(conference)
        end

        it 'changes conference attributes' do
          patch :update, id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con',
                                          short_title: 'ExCon')

          conference.reload
          expect(conference.title).to eq('Example Con')
          expect(conference.short_title).to eq('ExCon')
        end

        it 'redirects to the updated conference' do
          patch :update, id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con')
          conference.reload
          expect(response).to redirect_to edit_admin_conference_path(
                                              conference.short_title)
        end

        it 'sends email notification on conference date update' do
          mailer = double
          allow(mailer).to receive(:deliver)
          conference.email_settings = create(:email_settings)
          patch :update, id: conference.short_title, conference: attributes_for(:conference, start_date: Date.today + 2.days, end_date: Date.today + 4.days)
          conference.reload
          allow(Mailbot).to receive(:conference_date_update_mail).and_return(mailer)
        end
      end

      context 'invalid attributes' do
        it 'does not change conference attributes' do
          patch :update, id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con',
                                          short_title: nil)

          conference.reload
          expect(flash[:alert]).
              to eq("Updating conference failed. Short title can't be blank.")
          expect(conference.title).to eq('The dog and pony show')
          expect(conference.short_title).to eq("#{conference.short_title}")
        end

        it 're-renders the #show template' do
          patch :update, id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con',
                                          short_title: nil)

          expect(flash[:alert]).
              to eq("Updating conference failed. Short title can't be blank.")
          expect(response).to redirect_to edit_admin_conference_path(
                                              conference.short_title)
        end
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'saves the conference to the database' do
          expected = expect do
            post :create, conference:
                attributes_for(:conference, short_title: 'dps15')
          end
          expected.to change { Conference.count }.by 1
        end

        it 'redirects to conference#show' do
          post :create, conference:
              attributes_for(:conference, short_title: 'dps15')

          expect(response).to redirect_to admin_conference_path(
                                              assigns[:conference].short_title)
        end
      end

      context 'with invalid attributes' do
        it 'does not save the conference to the database' do
          expected = expect do
            post :create, conference:
                attributes_for(:conference, short_title: nil)
          end
          expected.to_not change { Conference.count }
        end

        it 're-renders the new template' do
          post :create, conference:
              attributes_for(:conference, short_title: nil)
          expect(response).to be_success
        end
      end

      context 'with duplicate conference short title' do
        it 'does not save the conference to the database' do
          conference
          expected = expect do
            post :create, conference:
                attributes_for(:conference, short_title: conference.short_title)
          end
          expected.to_not change { Conference.count }
        end

        it 're-renders the new template' do
          conference
          post :create, conference: attributes_for(:conference, short_title: conference.short_title)
          expect(response).to be_success
        end
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested conference to conference' do
        get :edit, id: conference.short_title
        expect(assigns(:conference)).to eq conference
      end

      it 'renders the show template' do
        get :edit, id: conference.short_title
        expect(response).to render_template :edit
      end
    end

    describe 'GET #show' do
      it 'assigns the requested conference to conference' do
        get :show, id: conference.short_title
        expect(assigns(:conference)).to eq conference
      end

      it 'renders the show template' do
        get :show, id: conference.short_title
        expect(response).to render_template :show
      end
    end

    describe 'GET #index' do
      context 'with more than 0 conferences' do
        it 'populates an array with conferences' do
          conference
          con2 = create(:conference)
          get :index
          expect(assigns(:conferences)).to match_array([conference, con2])
        end

        it 'assigns cfp_max an array with maximum weeks' do
          conference
          date = Date.new(2014, 05, 26)
          conference.call_for_paper = create(:call_for_paper,
                                             start_date: date,
                                             end_date: date + 14)
          get :index
          expect(assigns(:cfp_weeks)).to match_array([1, 2, 3])
        end

        it 'renders the index template' do
          conference
          get :index
          expect(response).to render_template :index
        end
      end

      context 'no conferences' do
        it 'redirect to new conference' do
          Conference.all.each do |c|
            c.destroy
          end
          sign_in create(:admin)
          get :index
          expect(response).to redirect_to new_admin_conference_path
        end
      end
    end

    describe 'GET #new' do
      it 'assigns a new conference to conference' do
        get :new
        expect(assigns(:conference)).to be_a_new(Conference)
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'GET #roles' do
      before(:each) do
        get :roles, id: conference.short_title
      end

      it 'assigns default value to selection' do
        expect(assigns(:selection)).to eq('organizer')
      end

      it 'finds the correct role' do
        expect(assigns(:role)).to eq([organizer_role])
      end

      it 'properly assigns role_users hash' do
        expect(assigns(:role_users)).to eq('organizer' => [organizer, organizer2])
      end

      it 'properly assigns roles variable' do
        expect(assigns(:roles)).to eq(['Organizer', 'CfP', 'Info Desk', 'Volunteers Coordinator', 'Attendee', 'Volunteer', 'Speaker', 'Sponsor', 'Press', 'Keynote Speaker', ])
      end
    end

    describe 'POST #roles' do
      before(:each) do
        post :roles, id: conference.short_title, user: { roles: 'CfP' }
      end

      it 'assigns selected value to selection' do
        expect(assigns(:selection)).to eq('cfp')
      end

      it 'sets role variable' do
        post :roles, id: conference.short_title, user: { roles: 'Organizer' }
        role = Role.where(name: 'organizer', resource: conference)
        expect(assigns(:role)).to eq(role)
      end

      it 'sets role variable (returns blank for nil role)' do
        expect(assigns(:role)).to eq([])
      end

      it 'sets role_users hash with blank' do
        expect(assigns(:role_users)).to eq('cfp' => [])
      end

      it 'sets role_users has with data' do
        organizer.add_role :cfp, conference
        post :roles, id: conference.short_title, user: { roles: 'CfP' }
        expect(assigns(:role_users)).to eq('cfp' => [organizer])
      end

      it 'sets roles variable' do
        expect(assigns(:roles)).to eq(['Organizer', 'CfP', 'Info Desk', 'Volunteers Coordinator', 'Attendee', 'Volunteer', 'Speaker', 'Sponsor', 'Press', 'Keynote Speaker', ])
      end
    end

    describe 'POST #add_user' do
      before(:each) do
        @new_user = create(:user, email: 'new_user@email.osem')
        post :add_user, id: conference.short_title, user: { email: 'new_user@email.osem' }, role: 'organizer'
      end

      it 'finds correct user' do
        expect(assigns(:user)).to eq(@new_user)
      end

      it 'sets role_users variable' do
        expect(assigns(:role_users)).to eq('organizer' => organizer_role.users)

        post :add_user, id: conference.short_title, user: { email: 'new_user@email.osem' }, role: 'cfp'
        expect(assigns(:role_users)).to eq('cfp' => [@new_user])
      end

      it 'assigns role to user' do
        expect(@new_user.roles).to eq([organizer_role])
      end

      it 'assigns second role to user' do
        post :add_user, id: conference.short_title, user: { email: @new_user.email }, role: 'cfp'
        cfp_role = Role.find_by(name: 'cfp', resource: conference)
        expect(@new_user.roles).to eq([organizer_role, cfp_role])
      end
    end

    describe 'DELETE #remove_user' do
      before(:each) do

      end

      it 'sets selection variable' do
        delete :remove_user, id: conference.short_title, user_id: organizer2.id, role: 'organizer'
        expect(assigns(:selection)).to eq('organizer')
      end

      it 'sets role_users hash' do
        delete :remove_user, id: conference.short_title, user_id: organizer2.id, role: 'organizer'
        expect(assigns(:role_users)).to eq('organizer' => [organizer])
      end

      it 'removes role from user' do
        delete :remove_user, id: conference.short_title, user_id: organizer2.id, role: 'organizer'
        organizer2.reload
        expect(organizer2.roles).to eq([])
      end

      it 'removes second role from user' do
        # Add cfp role
        organizer2.add_role :cfp, conference
        cfp_role = Role.find_by(name: 'cfp', resource: conference)
        # Remove role organizer
        delete :remove_user, id: conference.short_title, user_id: organizer2.id, role: 'organizer'

        organizer2.reload
        expect(organizer2.roles).to include(cfp_role)
        expect(organizer2.roles[0]).to eq(cfp_role)
        expect(organizer2.roles.count).to eq(1)
        expect(assigns(:role_users)).to eq('organizer' => [organizer])

        delete :remove_user, id: conference.short_title, user_id: organizer2.id, role: 'cfp'
        organizer2.reload
        expect(organizer2.roles).to eq([])
      end
    end
  end

  describe 'organizer access' do

    before do
      sign_in(organizer)
    end

    it_behaves_like 'access as organizer'

  end

  shared_examples 'access as participant or guest' do |path, message|
    describe 'GET #show' do
      it 'requires organizer privileges' do
        get :show, id: conference.short_title
        expect(response).to redirect_to(send(path))
        if message
          expect(flash[:alert]).to match(/#{message}/)
        end
      end
    end

    describe 'GET #index' do
      it 'requires organizer privileges' do
        get :index
        expect(response).to redirect_to(send(path))
        if message
          expect(flash[:alert]).to match(/#{message}/)
        end
      end
    end

    describe 'GET #new' do
      it 'requires organizer privileges' do
        get :new
        expect(response).to redirect_to(send(path))
        if message
          expect(flash[:alert]).to match(/#{message}/)
        end
      end
    end

    describe 'POST #create' do
      it 'requires organizer privileges' do
        post :create, conference: attributes_for(:conference,
                                                 short_title: 'ExCon')
        expect(response).to redirect_to(send(path))
        if message
          expect(flash[:alert]).to match(/#{message}/)
        end
      end
    end

    describe 'PATCH #update' do
      it 'requires organizer privileges' do
        patch :update, id: conference.short_title,
                       conference: attributes_for(:conference,
                                                  short_title: 'ExCon')
        expect(response).to redirect_to(send(path))
        if message
          expect(flash[:alert]).to match(/#{message}/)
        end
      end
    end
  end

  describe 'participant access' do
    before(:each) do
      sign_in(participant)
    end

    it_behaves_like 'access as participant or guest', :root_path, 'You are not authorized to access this area!'

  end

  describe 'guest access' do

    it_behaves_like 'access as participant or guest', :new_user_session_path

  end
end
