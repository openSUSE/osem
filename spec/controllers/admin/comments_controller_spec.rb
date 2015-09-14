require 'spec_helper'

describe Admin::CommentsController, type: :controller do

  context 'not logged in user' do
    describe 'GET #index' do
      it 'renders the :index template' do
        conference = create(:conference)
        first_user = create(:user)
        organizer_role = create(:role, name: 'organizer', resource: conference)
        organizer = create(:user, role_ids: organizer_role.id)
        event = create(:event, conference: conference)
        comment = create(:comment, commentable_type: 'Event', commentable_id: event.id)

        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  context 'logged in as admin, organizer or cfp' do
    describe 'GET #index' do
      it 'populates a hash with comments' do
        conference = create(:conference)
        first_user = create(:user)
        organizer_role = create(:role, name: 'organizer', resource: conference)
        organizer = create(:user, role_ids: organizer_role.id)
        event = create(:event, conference: conference)
        comment = create(:comment, commentable_type: 'Event', commentable_id: event.id)
        sign_in(organizer)

        get :index
        expect(assigns(:comments)).to be_a(Hash)
        # assigns(:comments).first returns an array of first pair key-value from hash.
        # Calling again 'first' returns the key, meaning the Conference object.
        expect(assigns(:comments).first.first.title).to eq(comment.commentable.conference.title)
      end
      it 'has status 200: OK' do
        conference = create(:conference)
        first_user = create(:user)
        organizer_role = create(:role, name: 'organizer', resource: conference)
        organizer = create(:user, role_ids: organizer_role.id)
        event = create(:event, conference: conference)
        comment = create(:comment, commentable_type: 'Event', commentable_id: event.id)
        sign_in(organizer)

        get :index
        expect(response).to have_http_status(:ok)
      end
      it 'renders the :index template' do
        conference = create(:conference)
        first_user = create(:user)
        organizer_role = create(:role, name: 'organizer', resource: conference)
        organizer = create(:user, role_ids: organizer_role.id)
        event = create(:event, conference: conference)
        comment = create(:comment, commentable_type: 'Event', commentable_id: event.id)
        sign_in(organizer)

        get :index
        expect(response).to render_template(:index)
      end
    end
  end

  context 'logged in with any other role or normal user' do
    describe 'GET#index' do
      it 'requires organizer privileges' do
        conference = create(:conference)
        first_user = create(:user)
        participant = create(:user)
        event = create(:event, conference: conference)
        comment = create(:comment, commentable_type: 'Event', commentable_id: event.id)
        sign_in(participant)

        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match('You are not authorized to access this area!')
      end
    end
  end
end
