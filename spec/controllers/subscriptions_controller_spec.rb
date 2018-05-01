# frozen_string_literal: true

require 'spec_helper'

describe SubscriptionsController do
  let(:conference) { create(:conference) }
  let(:user) { create(:user) }

  describe 'POST #create' do
    context 'when user is a guest' do
      it 'redirects to sign in page' do
        post :create, params: { conference_id: conference.short_title }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when user is signed in' do
      before(:each) do
        sign_in(user)
      end

      it 'redirects to home page' do
        post :create, params: { conference_id: conference.short_title }
        expect(response).to redirect_to root_path
      end

      it 'shows success message in flash notice' do
        post :create, params: { conference_id: conference.short_title }
        expect(flash[:notice]).to match("You have subscribed to receive email notifications for #{conference.title}")
      end

      it 'subscribes user to conference' do
        post :create, params: { conference_id: conference.short_title }
        expect(user.subscriptions.pluck(:conference_id)).to include(conference.id)
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      sign_in(user)
      post :create, params: { conference_id: conference.short_title }
    end

    it 'redirects to home page' do
      delete :destroy, params: { conference_id: conference.short_title }
      expect(response).to redirect_to root_path
    end

    it 'shows success message in flash notice' do
      delete :destroy, params: { conference_id: conference.short_title }
      expect(flash[:notice]).to match("You have unsubscribed and you will not be receiving email notifications for #{conference.title}.")
    end
  end
end
