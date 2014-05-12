require 'spec_helper'

describe Admin::UsersController do

  before(:each) do
    @user = create(:user)
    @admin = create(:admin)
    sign_in(@admin)
  end

  describe "GET '#index'" do
    
    it 'populates an array of users' do
      user1 = create(:user, email:"gopesh.7500@gmail.com")
      user2 = create(:user,email:"gopesh@gmail.com")
      get :index
      # pp response.body
      expect(assigns(:users)).to match_array([@user,@admin,user1,user2])
    end

    it 'renders index template' do
      get :index
      # pp response.body
      expect(response).to render_template :index
    end
  end
end