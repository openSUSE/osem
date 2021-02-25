# frozen_string_literal: true

require 'spec_helper'

describe Admin::ConferencesController do

  # It is necessary to use bang version of let to build roles before user
  let!(:organization) { create(:organization, name: 'organization') }
  let!(:conference) { create(:conference, organization: organization, end_date: Date.new(2014, 05, 26) + 15) }
  let!(:organization_admin_role) { Role.find_by(name: 'organization_admin', resource: organization) }
  let(:organization_admin) { create(:user, role_ids: organization_admin_role.id) }
  let(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:organizer, resource: conference) }
  let!(:organizer2) { create(:organizer, email: 'organizer2@email.osem', resource: conference) }
  let(:participant) { create(:user) }

  shared_examples 'access as organizer or organization_admin' do
    describe 'PATCH #update' do
      context 'valid attributes' do
        it 'locates the requested conference' do
          patch :update, params: { id: conference.short_title, conference: attributes_for(:conference, title: 'Example Con') }
          expect(assigns(:conference)).to eq(conference)
        end

        it 'changes conference attributes' do
          patch :update, params: { id: conference.short_title, conference:
              attributes_for(:conference, title:       'Example Con',
                                          short_title: 'ExCon') }
          conference.reload
          expect(conference.title).to eq('Example Con')
          expect(conference.short_title).to eq('ExCon')
        end

        it 'redirects to the updated conference' do
          patch :update, params: { id: conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con') }
          conference.reload
          expect(response).to redirect_to edit_admin_conference_path(
                                              conference.short_title)
        end

        it 'sends email notification on conference date update' do
          mailer = double
          allow(mailer).to receive(:deliver)
          conference.email_settings = create(:email_settings)
          patch :update, params: { id: conference.short_title, conference: attributes_for(:conference, start_date: Time.zone.today + 2.days, end_date: Time.zone.today + 4.days) }
          conference.reload
          allow(Mailbot).to receive(:conference_date_update_mail).and_return(mailer)
        end
      end

      context 'invalid attributes' do
        it 'does not change conference attributes' do
          patch :update, params: { id: conference.short_title, conference:
              attributes_for(:conference, title:       'Example Con',
                                          short_title: nil) }

          conference.reload
          expect(flash[:error])
              .to eq("Updating conference failed. Short title can't be blank.")
          expect(conference.title).to eq(conference.title)
          expect(conference.short_title).to eq(conference.short_title)
        end

        it 're-renders the #show template' do
          patch :update, params: { id: conference.short_title, conference:
              attributes_for(:conference, title:       'Example Con',
                                          short_title: nil) }

          expect(flash[:error])
              .to eq("Updating conference failed. Short title can't be blank.")
          expect(response).to redirect_to edit_admin_conference_path(
                                              conference.short_title)
        end
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested conference to conference' do
        get :edit, params: { id: conference.short_title }
        expect(assigns(:conference)).to eq conference
      end

      it 'renders the show template' do
        get :edit, params: { id: conference.short_title }
        expect(response).to render_template :edit
      end
    end

    describe 'GET #show' do
      it 'assigns the requested conference to conference' do
        get :show, params: { id: conference.short_title }
        expect(assigns(:conference)).to eq conference
      end

      it 'renders the show template' do
        get :show, params: { id: conference.short_title }
        expect(response).to render_template :show
      end

      # TODO-SNAPCON: This is currently disabled due to slow performance.
      skip 'assigns conference withdrawn events distribution to event_type_distribution_withdrawn' do
        conference
        create(:event, program: conference.program)
        workshop = create(:event_type, title: 'Workshop', color: '#000000', program: conference.program)
        lecture = create(:event_type, title: 'Lecture', color: '#ffffff', program: conference.program)
        get :show, params: { id: conference.short_title }
        expect(assigns(:event_type_distribution_withdrawn)).to be_empty
        create(:event, program: conference.program, state: 'withdrawn', event_type: lecture)
        create(:event, program: conference.program, state: 'withdrawn', event_type: workshop)
        get :show, params: { id: conference.short_title }
        expect(assigns(:event_type_distribution_withdrawn)).not_to be_empty
        result = {}
        result['Workshop'] = {
          'value' => 1,
          'color' => '#000000'
        }
        result['Lecture'] = {
          'value' => 1,
          'color' => '#FFFFFF'
        }
        expect(assigns(:event_type_distribution_withdrawn)).to eq(result)
      end

      # TODO-SNAPCON: This is currently disabled due to slow performance.
      skip 'assigns conference withdrawn difficulty level distribution to difficulty_levels_distribution_withdrawn' do
        conference
        create(:event, program: conference.program)
        get :show, params: { id: conference.short_title }
        expect(assigns(:difficulty_levels_distribution_withdrawn)).to be_empty
        easy = create(:difficulty_level, title: 'Easy', color: '#000000')
        hard = create(:difficulty_level, title: 'Hard', color: '#ffffff')
        create(:event, program: conference.program, state: 'withdrawn', difficulty_level: easy)
        create(:event, program: conference.program, state: 'withdrawn', difficulty_level: hard)
        get :show, params: { id: conference.short_title }
        expect(assigns(:difficulty_levels_distribution_withdrawn)).not_to be_empty
        result = {}
        result['Easy'] = {
          'value' => 1,
          'color' => '#000000'
        }
        result['Hard'] = {
          'value' => 1,
          'color' => '#FFFFFF'
        }
        expect(assigns(:difficulty_levels_distribution_withdrawn)).to eq(result)
      end

      # TODO-SNAPCON: This is currently disabled due to slow performance.
      skip 'assigns conference withdrawn track distribution to tracks_distribution_withdrawn' do
        conference
        create(:event, program: conference.program)
        get :show, params: { id: conference.short_title }
        expect(assigns(:tracks_distribution_withdrawn)).to be_empty
        track_one = create(:track, name: 'Track One', color: '#000000', program: conference.program)
        track_two = create(:track, name: 'Track Two', color: '#FFFFFF', program: conference.program)
        create(:event, program: conference.program, state: 'withdrawn', track: track_one)
        create(:event, program: conference.program, state: 'withdrawn', track: track_two)
        get :show, params: { id: conference.short_title }
        expect(assigns(:tracks_distribution_withdrawn)).not_to be_empty
        result = {}
        result['Track One'] = {
          'value' => 1,
          'color' => '#000000'
        }
        result['Track Two'] = {
          'value' => 1,
          'color' => '#FFFFFF'
        }
        expect(assigns(:tracks_distribution_withdrawn)).to eq(result)
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
  end

  shared_examples 'access as organization_admin' do
    describe 'POST #create' do
      context 'with valid attributes' do
        it 'saves the conference to the database' do
          expected = expect do
            post :create, params: { conference:
                                                attributes_for(:conference, short_title: 'dps15', organization_id: organization.id) }
          end
          expected.to change { Conference.count }.by 1
        end

        it 'redirects to conference#show' do
          post :create, params: { conference:
                                              attributes_for(:conference, short_title: 'dps15', organization_id: organization.id) }

          expect(response).to redirect_to admin_conference_path(
                                              assigns[:conference].short_title)
        end

        it 'creates roles for the conference' do
          cfp_role = Role.find_by(name: 'cfp', resource: conference)
          info_desk_role = Role.find_by(name: 'info_desk', resource: conference)
          volunteers_coordinator_role = Role.find_by(name: 'volunteers_coordinator', resource: conference)

          post :create, params: { conference:
                                              attributes_for(:conference, short_title: 'dps15') }

          expect(conference.roles.count).to eq 4

          expect(conference.roles).to match_array [organizer_role, cfp_role, info_desk_role, volunteers_coordinator_role]
        end
      end

      context 'with invalid attributes' do
        it 'does not save the conference to the database' do
          expected = expect do
            post :create, params: { conference:
                                                attributes_for(:conference, short_title: nil, organization_id: organization.id) }
          end
          expected.to_not change { Conference.count }
        end

        it 're-renders the new template' do
          post :create, params: { conference:
                                              attributes_for(:conference, short_title: nil, organization_id: organization.id) }
          expect(response).to be_success
        end
      end

      context 'with duplicate conference short title' do
        it 'does not save the conference to the database' do
          conference
          expected = expect do
            post :create, params: { conference:
                                                attributes_for(:conference, short_title: conference.short_title, organization_id: organization.id) }
          end
          expected.to_not change { Conference.count }
        end

        it 're-renders the new template' do
          conference
          post :create, params: { conference: attributes_for(:conference, short_title: conference.short_title, organization_id: organization.id) }
          expect(response).to be_success
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
  end

  describe 'organization admin access' do
    before do
      sign_in(organization_admin)
    end

    it_behaves_like 'access as organizer or organization_admin'
    it_behaves_like 'access as organization_admin'
  end

  shared_examples 'access as organizer, participant or guest' do |path, message|
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
        post :create, params: { conference: attributes_for(:conference,
                                                           short_title: 'ExCon', organization_id: organization.id) }
        expect(response).to redirect_to(send(path))
        if message
          expect(flash[:alert]).to match(/#{message}/)
        end
      end
    end
  end

  describe 'organizer access' do
    before do
      sign_in(organizer)
    end

    it_behaves_like 'access as organizer or organization_admin'
    it_behaves_like 'access as organizer, participant or guest', :root_path, 'You are not authorized to access this page.'
  end

  shared_examples 'access as participant or guest' do |path, message|
    describe 'GET #show' do
      it 'requires organizer privileges' do
        get :show, params: { id: conference.short_title }
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

    describe 'PATCH #update' do
      it 'requires organizer privileges' do
        patch :update, params: { id:         conference.short_title,
                                 conference: attributes_for(:conference,
                                                            short_title: 'ExCon') }
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

    it_behaves_like 'access as participant or guest', :root_path, 'You are not authorized to access this page.'
    it_behaves_like 'access as organizer, participant or guest', :root_path, 'You are not authorized to access this page.'
  end

  describe 'guest access' do

    it_behaves_like 'access as participant or guest', :new_user_session_path
    it_behaves_like 'access as organizer, participant or guest', :new_user_session_path
  end
end
