require 'spec_helper'
describe Admin::UsersController do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  before(:each) do
    sign_in(admin)
  end
  describe 'GET #index' do
    it 'populates an array of users' do
      user1 = create(:user, email: 'user1@email.osem')
      user2 = create(:user, email: 'user2@email.osem')
      user_deleted = User.find_by(name: 'User deleted')
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
      patch :toggle_confirmation, id: user_to_confirm.id, user: { to_confirm: 'true' }
      user_to_confirm.reload
      expect(user_to_confirm.confirmed?).to eq true
    end
    it 'undo confirmation of user' do
      patch :toggle_confirmation, id: user.id, user: { to_confirm: 'false' }
      user.reload
      expect(user.confirmed?).to eq false
    end
  end
  describe 'PATCH #update' do
    context 'valid attributes' do
      before :each do
        patch :update, id: user.id, user: { name: 'new name', email: 'new_email@osem.io' }
      end

      it 'locates requested @user' do
        expect(build(:user, id: user.id)).to eq(user)
      end
      it 'changes @users attributes' do
        expect(build(
          :user, email: 'email_new@osem.io', id: user.id).email).
              to eq('email_new@osem.io')
      end
      it 'redirects to the updated user' do
        expect(response).to redirect_to admin_users_path
      end
    end
  end
end
