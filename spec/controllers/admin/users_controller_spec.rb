require 'spec_helper'

describe Admin::UsersController do
  shared_examples 'access as administration' do
  	describe "GET '#index'" do
      it 'populates an array of users' do
        user1,user2 = create(:user,email:"gopesh.7500@gmail.com"),create(:user,email:"gopesh@gmail.com")
        get :index
        expect(assigns(:users)).to match_array([user1,user2])
      end
      
      it 'renders index template' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe "PATCH '#update'" do
      it 'locates the user' do
        patch :update, id: @user.id, :user => {email:@user.email}
        expect(assigns(:user)).to eq(@user)
      end
    end

    describe 'admin access' do
      before(:each) do
        @user = create(:user)
        @admin = create(:admin)
        sign_in(@admin)
      end
      it_behaves_like 'access as administration'
    end
  end
end
