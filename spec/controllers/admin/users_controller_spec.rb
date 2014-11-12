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
      get :index
      expect(assigns(:users)).to match_array([user, admin, user1, user2])
    end
    it 'renders index template' do
      get :index
      expect(response).to render_template :index
    end
  end
  describe 'PATCH #update' do
    context 'valid attributes' do
      it 'locates requested @user' do
        patch :update, id: user.id
        expect(build(:user, id: user.id)).to eq(user)
      end
      it 'changes @users attributes' do
        patch :update, id: user.id
        expect(build(
          :user, email: 'new@email.osem', id: user.id).email).
              to eq('new@email.osem')
      end
      it 'redirects to the updated user' do
        patch :update, id: user.id
        expect(response).to redirect_to admin_users_path
      end
    end
  end
  describe 'DELETE #destroy' do
    before :each do
      @user = create(:user)
    end
    context 'valid attributes' do
      it 'it deletes the contact' do
        expect { delete :destroy, id: @user.id }.to change(User, :count).by(-1)
      end
      it 'redirects to users#index' do
        delete :destroy, id: @user
        expect(response).to redirect_to admin_users_path
      end
    end
  end

end
