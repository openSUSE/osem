require 'spec_helper'

describe User do

  # It is necessary to use bang version of let to build roles before user
  let!(:user_admin) { create(:user) }
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:cfp_role) { create(:cfp_role, resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }
  let!(:user) { create(:user) }

  it 'User.for_ichain_username raises exception if user is disabled' do
    user.is_disabled = true
    user.save
    expect{User.for_ichain_username(user.username, email: user.email)}.to raise_error(UserDisabled)
  end

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

    context 'participant' do
      it_behaves_like '#role?', :user, 'adMin', false
    end
  end

  describe 'assigns admin attribute' do
    it 'to second user when first user is deleted_user' do
      DatabaseCleaner.clean_with(:truncation)

      deleted_user = create(:user, email: 'deleted@localhost.osem', name: 'User deleted')
      expect(deleted_user.is_admin).to be false

      user_after_deleted = create(:user)
      expect(user_after_deleted.is_admin).to be true
    end
  end

  describe 'does not assign admin attribute' do
    it 'when first user is not deleted_user' do
      DatabaseCleaner.clean_with(:truncation)

      first_user = create(:user)
      expect(first_user.is_admin).to be false

      second_user = create(:user)
      expect(second_user.is_admin).to be false
    end
  end
end
