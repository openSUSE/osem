# frozen_string_literal: true

require 'spec_helper'

describe Admin::CommentsController, type: :controller do

  # It is necessary to use bang version of let to build roles before user
  let(:conference) { create(:conference) }
  let(:organizer) { create(:organizer, resource: conference, last_sign_in_at: Time.now - 1.day) }
  let(:participant) { create(:user) }
  let(:event) { create(:event, program: conference.program) }
  let(:comment) { create(:comment, commentable_type: 'Event', commentable_id: event.id) }

  context 'not logged in user' do
    describe 'GET #index' do
      it 'renders the :index template' do
        comment
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  context 'logged in as admin, organizer or cfp' do
    before :each do
      sign_in(organizer)
      comment
    end
    describe 'GET #index' do
      it 'populates a hash with comments' do
        get :index
        expect(assigns(:comments)).to be_a(Hash)
        # assigns(:comments).first returns an array of first pair key-value from hash.
        # Calling again 'first' returns the key, meaning the Conference object.
        expect(assigns(:comments).first.first.title).to eq(comment.commentable.program.conference.title)
      end
      it 'has status 200: OK' do
        get :index
        expect(response).to have_http_status(:ok)
      end
      it 'renders the :index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end

  context 'logged in with any other role or normal user' do
    describe 'GET#index' do
      it 'requires organizer privileges' do
        sign_in(participant)
        comment
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match('You are not authorized to access this page.')
      end
    end
  end
end
