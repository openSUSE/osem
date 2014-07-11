require 'spec_helper'
describe Admin::UsersController do
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let(:organizer) { create(:organizer) }
  let(:user) { create(:user) }
  before(:each) do
    sign_in(organizer)
  end
  describe 'GET #index' do
    it 'populates an array of users' do
      user1 = create(:user, email: 'gopesh.7500@gmail.com')
      user2 = create(:user, email: 'gopesh_750@gmail.com')
      get :index
      expect(assigns(:users)).to match_array([user, organizer, user1, user2])
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
          :user, email: 'example@incoherent.de', id: user.id).email).
              to eq('example@incoherent.de')
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
