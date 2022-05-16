# frozen_string_literal: true

require 'spec_helper'

describe ApplicationController, type: :controller do
  let(:conference) { create(:conference) }

  describe 'user is signed in' do

    describe 'as admin' do
      let(:admin) { create(:admin) }
      before { sign_in(admin) }

      it 'redirects to the admin homepage' do
        expect(controller.after_sign_in_path_for(admin)).to eq admin_conferences_path
      end
    end

    describe 'as regular user' do
      let(:user) { create(:user) }
      before { sign_in(user) }

      context 'with no return_to value in the session' do
        it 'redirects to the root_path' do
          expect(controller.after_sign_in_path_for(user)).to eq root_path
        end
      end

      context 'with a specific return_to value provided in the session' do
        it 'redirects to the conferences_path' do
          @request.session['return_to'] = conferences_path
          expect(controller.after_sign_in_path_for(user)).to eq conferences_path
        end
      end
    end
  end
end
