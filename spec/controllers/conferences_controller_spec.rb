#!/bin/env ruby
# encoding: utf-8
require 'spec_helper'

describe Admin::ConferenceController do

  shared_examples 'access as administration or organizer' do

    describe 'PATCH #update' do
      context 'valid attributes' do
        it 'locates the requested @conference' do
          patch :update, id: @conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con')

          expect(assigns(:conference)).to eq(@conference)
        end

        it 'changes @conference attributes' do
          patch :update, id: @conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con',
                                          short_title: 'ExCon')

          @conference.reload
          expect(@conference.title).to eq('Example Con')
          expect(@conference.short_title).to eq('ExCon')
        end

        it 'redirects to the updated @conference' do
          patch :update, id: @conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con')

          expect(response).to redirect_to admin_conference_path(
                                              @conference.short_title)
        end
      end

      context 'invalid attributes' do
        it 'does not change conference attributes' do
          patch :update, id: @conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con',
                                          short_title: nil)

          @conference.reload
          expect(@conference.title).to eq('The dog and pony show')
          expect(@conference.short_title).to eq('dps14')
        end

        it 're-renders the #show template' do
          patch :update, id: @conference.short_title, conference:
              attributes_for(:conference, title: 'Example Con',
                                          short_title: nil)

          expect(response).to redirect_to admin_conference_path(
                                              @conference.short_title)
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
          expect(response).to render_template :new
        end
      end

      context 'with duplicate conference short title' do
        it 'does not save the conference to the database' do
          expected = expect do
            post :create, conference:
                attributes_for(:conference)
          end
          expected.to_not change { Conference.count }
        end

        it 're-renders the new template' do
          post :create, conference: attributes_for(:conference)
          expect(response).to render_template :new
        end
      end
    end

    describe 'GET #show' do
      it 'assigns the requested conference to @conference' do
        get :show, id: @conference.short_title
        expect(assigns(:conference)).to eq @conference
      end

      it 'renders the show template' do
        get :show, id: @conference.short_title
        expect(response).to render_template :show
      end
    end

    describe 'GET #index' do
      it 'populates an array with conferences' do
        con2 = create(:conference, short_title: 'dps15',
                                   title: 'The dog and pony show 2015')
        get :index
        expect(assigns(:conferences)).to match_array([@conference, con2])
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it 'assigns a new conference to @conference' do
        get :new
        expect(assigns(:conference)).to be_a_new(Conference)
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end
  end

  describe 'administrator access' do
    before(:each) do
      @conference = create(:conference)
      @admin = create(:admin)
      sign_in(@admin)
    end

    it_behaves_like 'access as administration or organizer'

  end

  describe 'organizer access' do
    before(:each) do
      @conference = create(:conference)
      @organizer = create(:organizer)
      sign_in(@organizer)
    end

    it_behaves_like 'access as administration or organizer'

  end

  shared_examples 'access as participant or guest' do |success_path|
    describe 'GET #show' do
      it 'requires admin privileges' do
        get :show, id: @conference.short_title
        expect(response).to redirect_to(send(success_path))
      end
    end

    describe 'GET #index' do
      it 'requires admin privileges' do
        get :index
        expect(response).to redirect_to(send(success_path))
      end
    end

    describe 'GET #new' do
      it 'requires admin privileges' do
        get :new
        expect(response).to redirect_to(send(success_path))
      end
    end

    describe 'POST #create' do
      it 'requires admin privileges' do
        post :create, conference: attributes_for(:conference,
                                                 short_title: 'ExCon')
        expect(response).to redirect_to(send(success_path))
      end
    end

    describe 'PATCH #update' do
      it 'requires admin privileges' do
        patch :update, id: @conference.short_title,
                       conference: attributes_for(:conference,
                                                  short_title: 'ExCon')
        expect(response).to redirect_to(send(success_path))
      end
    end
  end

  describe 'participant access' do
    before(:each) do
      @conference = create(:conference)
      @participant = create(:participant)
      sign_in(@participant)
    end

    it_behaves_like 'access as participant or guest', :root_path

  end

  describe 'guest access' do

    before(:each) do
      @conference = create(:conference)
    end

    it_behaves_like 'access as participant or guest', :new_user_session_path

  end
end
