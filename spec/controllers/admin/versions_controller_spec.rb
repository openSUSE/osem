# frozen_string_literal: true

require 'spec_helper'

describe Admin::VersionsController do

  let!(:conference) { create(:conference, short_title: 'exampletitle', description: 'Example Description') }
  let(:admin) { create(:admin) }
  let(:role_organizer) { conference.roles.find_by(name: 'organizer') }
  let(:role_cfp) { conference.roles.find_by(name: 'cfp') }
  let(:role_info_desk) { conference.roles.find_by(name: 'info_desk') }

  with_versioning do
    describe 'GET #revert' do
      before :each do
        sign_in admin
      end

      it 'reverts all changes for update actions' do
        conference.update(short_title: 'testtitle', description: 'Some random text')
        get :revert_object, params: { id: conference.versions.last.id }
        conference.reload
        expect(conference.short_title).to eq 'exampletitle'
        expect(conference.description).to eq 'Example Description'
      end

      it 'shows correct flash on trying to revert create event of a deleted object' do
        creation_version_id = conference.program.event_types.first.versions.first.id
        conference.program.event_types.first.destroy
        get :revert_object, params: { id: creation_version_id }
        expect(flash[:error]).to match('The item is already in the state that you are trying to revert it back to')
      end

      it 'reverting deletion of object creates it again' do
        event_type = conference.program.event_types.first
        event_type.destroy
        event_types_count = conference.program.event_types.count
        get :revert_object, params: { id: event_type.versions.last.id }
        conference.reload
        expect(event_type.versions.last.event).to eq 'create'
        expect(conference.program.event_types.count).to eq(event_types_count + 1)
      end

      it 'reverting creation of object deletes it' do
        lodging = create(:lodging, conference: conference)
        get :revert_object, params: { id: lodging.versions.last.id }
        expect(lodging.versions.last.event).to eq 'destroy'
        expect(Lodging.count).to eq 0
      end

      it 'reverting creation of conference is not permitted' do
        conference_count_before = Conference.count
        get :revert_object, params: { id: conference.versions.first.id }
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
        expect(Conference.count).to eq(conference_count_before)
      end
    end

    describe 'GET #revert_attribute' do
      before :each do
        sign_in admin
      end

      it 'reverts specified change for update actions' do
        conference.update(short_title: 'testtitle', description: 'Some random text')
        get :revert_attribute, params: { id: conference.versions.last.id, attribute: 'short_title' }
        conference.reload
        expect(conference.short_title).to eq 'exampletitle'
        expect(conference.description).to eq 'Some random text'
      end

      it 'shows correct flash on trying to revert to the current state' do
        conference.update(short_title: 'testtitle', description: 'Some random text')
        conference.update_attribute(:short_title, 'exampletitle')
        get :revert_attribute, params: { id: conference.versions[-2].id, attribute: 'short_title' }
        expect(flash[:error]).to match('The item is already in the state that you are trying to revert it back to')
        expect(conference.short_title).to eq 'exampletitle'
      end

      it 'fails on trying to revert deleted object' do
        event_type = conference.program.event_types.first
        event_type.update_attribute(:title, 'New Event Title')
        event_type.destroy
        get :revert_attribute, params: { id: event_type.versions[-2].id, attribute: 'title' }
        conference.reload
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end

      it 'fails on trying to revert creation event' do
        lodging = create(:lodging, conference: conference)
        get :revert_attribute, params: { id: lodging.versions.last.id, attribute: 'name' }
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end

      it 'revert fails when attribute is invalid' do
        conference.update(short_title: 'testtitle', description: 'Some random text')
        before_conference_title = conference.title
        # Note: even though title is a valid attribute of conference, it was not updated in the change we are trying to revert
        get :revert_attribute, params: { id: conference.versions.last.id, attribute: 'title' }
        conference.reload
        expect(conference.short_title).to eq 'testtitle'
        expect(conference.description).to eq 'Some random text'
        expect(conference.title).to eq(before_conference_title)
        expect(flash[:error]).to match('Revert failed. Attribute missing or invalid')
      end
    end

    describe 'GET #index' do
      it 'raises error if user is not of any role' do
        user = create(:user)
        sign_in user
        get :index, params: { conference_id: conference.short_title }
        expect(flash[:alert]).to match('You are not authorized to access this page.')
      end

      context 'with conference' do
        before :each do
          @user = create(:user)

          conference.update(short_title: 'testtitle', description: 'Some random text')
          @version_organizer = conference.versions.last
          cfp = create(:cfp, program: conference.program)
          @version_cfp = cfp.versions.last
          registration = create(:registration, conference: conference)
          registration.update_attribute(:attended, true)
          @version_info_desk = registration.versions.last
        end

        it 'when user has role cfp' do
          @user.roles = [role_cfp]
          sign_in @user
          get :index, params: { conference_id: conference.short_title }

          expect(assigns(:versions).include?(@version_cfp)).to be true
          expect(assigns(:versions).include?(@version_organizer)).to be false
        end

        it 'when user has role info_desk' do
          @user.roles = [role_info_desk]
          sign_in @user
          get :index, params: { conference_id: conference.short_title }

          expect(assigns(:versions).include?(@version_info_desk)).to be true
          expect(assigns(:versions).include?(@version_organizer)).to be false
          expect(assigns(:versions).include?(@version_cfp)).to be false
        end

        it 'when user has role organizer' do
          @user.roles = [role_organizer]
          sign_in @user
          get :index, params: { conference_id: conference.short_title }

          expect(assigns(:versions).include?(@version_organizer)).to be true
          expect(assigns(:versions).include?(@version_cfp)).to be true
          expect(assigns(:versions).include?(@version_info_desk)).to be true
        end
      end
    end
  end
end
