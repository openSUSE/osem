require 'spec_helper'
describe Admin::UsersController do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  before(:each) do
    sign_in(admin)
  end
  describe 'GET #index' do
    it 'populates an array of users' do
      user1 = create(:user, email: 'gopesh.7500@gmail.com')
      user2 = create(:user, email: 'gopesh_750@gmail.com')
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

  describe 'GET #new' do
    it 'assigns a new user to @user variable' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'renders the :new template' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'saves the user to the database' do
        expected = expect do
          post :create, user: { name: 'New User', email: 'newuser@osem.localhost' }
        end
        expected.to change { User.count }.by 1
      end

      it 'redirects to users#index' do
        post :create, user: { name: 'New User', email: 'newuser@osem.localhost' }
        expect(response).to redirect_to admin_users_path
      end

      it 'shows success message' do
        post :create, user: { name: 'New User', email: 'newuser@osem.localhost' }
        expect(flash[:notice]).to match('User created. Name: New User, email: newuser@osem.localhost')
      end
    end

    context 'with invalid attributes' do
      it 'does not save the user to the database' do
        expected = expect do
          post :create
        end
        expected.to_not change { User.count }
      end

      it 're-renders the new template' do
        post :create

        expect(response).to be_success
      end
    end
  end
end
