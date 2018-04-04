# frozen_string_literal: true

require 'spec_helper'

describe UsersController do
  let!(:first_user) { create(:user) }
  let!(:user) { create(:user, name: 'My Name') }

  describe 'GET #show' do
    before :each do
      get :show, params: { id: user.id }
    end

    it 'renders show template' do
      expect(response).to render_template :show
    end

    it 'assigns the right value to @user' do
      expect(assigns(:user)).to eq user
    end

    it 'assigns [] to @events, when user does not have any submissions' do
      expect(assigns(:events)).to eq []
    end

    it 'assigns the correct value to @events, when the user has submissions' do
      conference = create(:conference)
      event = create(:event, state: 'confirmed', program: conference.program)
      event.event_users << create(:event_user, user: user, event_role: 'submitter')

      expect(assigns(:events)).to eq [event]
    end
  end

  describe 'GET #edit' do
    it 'assigns the right value to @user' do
      sign_in user
      get :edit, params: { id: user.id }
      expect(assigns(:user)).to eq user
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      before :each do
        sign_in user
        patch :update, params: { id: user.id, user: attributes_for(:user, name: 'My Test Name') }
        user.reload
      end

      it 'assigns the right value to @user' do
        expect(assigns(:user)).to eq user
      end

      it 'changes user attributes' do
        expect(user.name).to eq 'My Test Name'
      end

      it 'redirects to show' do
        expect(response).to redirect_to(user_path(user))
      end

      it 'shows flash message' do
        expect(flash[:notice]).to eq 'User was successfully updated.'
      end
    end
  end
end
