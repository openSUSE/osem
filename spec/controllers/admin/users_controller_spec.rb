# frozen_string_literal: true

require 'spec_helper'
describe Admin::UsersController do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  before(:each) do
    sign_in(admin)
  end
  describe 'GET #index' do
    xit 'sets up users array with existing users records' do
      user1 = create(:user, email: 'user1@email.osem')
      user2 = create(:user, email: 'user2@email.osem')
      user_deleted = User.find_by!(username: 'deleted_user')
      get :index
      expect(assigns(:users)).to match_array([user_deleted, user, admin, user1, user2])
    end
    it 'renders index template' do
      get :index
      expect(response).to render_template :index
    end
  end
  describe 'PATCH #toggle_confirmation' do
    it 'confirms user' do
      user_to_confirm = create(:user, email: 'unconfirmed_user@osem.io', confirmed_at: nil)
      patch :toggle_confirmation, params: { id: user_to_confirm.id, user: { to_confirm: 'true' } }
      user_to_confirm.reload
      expect(user_to_confirm.confirmed?).to eq true
    end
    it 'undo confirmation of user' do
      patch :toggle_confirmation, params: { id: user.id, user: { to_confirm: 'false' } }
      user.reload
      expect(user.confirmed?).to eq false
    end
  end
  describe 'PATCH #update' do
    context 'valid attributes' do
      before :each do
        patch :update, params: { id: user.id, user: { name: 'new name', email: 'new_email@osem.io' } }
      end

      it 'locates requested @user' do
        expect(build(:user, id: user.id)).to eq(user)
      end
      it 'changes @users attributes' do
        expect(build(
          :user, email: 'email_new@osem.io', id: user.id).email)
              .to eq('email_new@osem.io')
      end
      it 'redirects to the updated user' do
        expect(response).to redirect_to admin_users_path
      end
    end
  end
  describe 'GET #new' do
    it 'sets up a user instance for the form' do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end
    it 'renders new user template' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'saves successfuly' do
      before do
        post :create, params: { user: attributes_for(:user) }
      end

      it 'redirects to admin users index path' do
        expect(response).to redirect_to admin_users_path
      end

      it 'shows success message in flash notice' do
        expect(flash[:notice]).to match('User successfully created.')
      end

      it 'creates new user' do
        expect(User.find(user.id)).to be_instance_of(User)
      end
    end

    context 'save fails' do
      before do
        allow_any_instance_of(User).to receive(:save).and_return(false)
        post :create, params: { user: attributes_for(:user) }
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end

      it 'shows error in flash message' do
        expect(flash[:error]).to match("Creating User failed: #{user.errors.full_messages.join('. ')}.")
      end

      it 'does not create new user' do
        expect do
          post :create, params: { user: attributes_for(:user) }
        end.not_to change{ Event.count }
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      delete :destroy, params: { id: user.id }
    end
    it 'redirects to admin users index path' do
      expect(response).to redirect_to admin_users_path
    end

    it 'shows success message in flash notice' do
      expect(flash[:notice]).to match("User #{user.id} (#{user.email}) deleted.")
    end

    it 'deletes the user' do
      expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
