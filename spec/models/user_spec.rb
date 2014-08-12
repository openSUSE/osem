require 'spec_helper'

describe User do

  # It is necessary to use bang version of let to build roles before user
  let!(:user_admin) { create(:user) }
  let!(:admin) { create(:admin) }
  let!(:participant) { create(:user) }
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:cfp_role) { create(:cfp_role, resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  it 'returns the correct role' do
    expect(user_admin.is_admin).to eq(true)
    expect(organizer.roles.first).to eq(organizer_role)
  end

  it 'returns the correct roles' do
    roles = [organizer_role.id, cfp_role.id]
    another_user = create(:user, email: 'participant@example.de')
    another_user.role_ids = roles
    another_user.save

    expect(another_user.roles.length).to eq(2)
    expect(another_user.roles[0]).to eq(organizer_role)
    expect(another_user.roles[1]).to eq(cfp_role)
  end

  describe '#has_role?' do
    shared_examples '#role?' do |user, role, expected|
      it "returns #{expected} for #{role}" do
        user_obj = create(user)
        expect(user_obj.has_role?(role.downcase, conference)).to be expected
      end
    end

    context 'organizer' do
      it_behaves_like '#role?', :organizer, 'organizer', true
      it_behaves_like '#role?', :organizer, 'participant', false
    end

    context 'admin' do
      it 'assigns first user admin role' do
        expect(User.first.is_admin).to be true
      end
    end

    context 'participant' do
      it_behaves_like '#role?', :user, 'adMin', false
    end
  end
end
