require 'spec_helper'

describe User do

  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }
  let!(:admin) { create(:user) }

  it 'returns the correct role' do
    participant = create(:user, email: 'participant@example.de')
    expect(admin.roles.first).to eq(admin_role)
    expect(participant.roles.first).to eq(participant_role)
  end

  it 'returns the correct roles' do
    roles = [organizer_role.id, participant_role.id, admin_role.id]
    user_with_all_roles = create(:user, email: 'participant@example.de')
    user_with_all_roles.role_ids = roles
    user_with_all_roles.save

    expect(user_with_all_roles.roles.length).to eq(3)
    expect(user_with_all_roles.roles[0]).to eq(participant_role)
    expect(user_with_all_roles.roles[1]).to eq(organizer_role)
    expect(user_with_all_roles.roles[2]).to eq(admin_role)
  end

  describe '#role?' do
    shared_examples '#role?' do |user, role, expected|
      it "returns #{expected} for #{role}" do
        user_obj = create(user, email: 'e@example.com')
        expect(user_obj.role?(role)).to be expected
        expect(user_obj.role?(role.downcase)).to be expected
        expect(user_obj.role?(role.upcase)).to be expected
        expect(user_obj.role?(role.downcase.capitalize)).to be expected
      end
    end

    context 'admin' do
      it_behaves_like '#role?', :admin, 'orgAnizer', false
      it_behaves_like '#role?', :admin, 'adMin', true
      it_behaves_like '#role?', :admin, 'partiCipant', false

      it 'assigns first user admin role' do
        expect(admin.role?('Admin')).to be true
        expect(admin.role_ids).to match_array([admin_role.id])
      end
    end

    context 'participant' do
      it_behaves_like '#role?', :participant, 'orgAnizer', false
      it_behaves_like '#role?', :participant, 'adMin', false
      it_behaves_like '#role?', :participant, 'partiCipant', true

      it 'assigns second user participant role' do
        participant = create(:user, email: 'participant@example.de')
        expect(participant.role_ids).to match_array([participant_role.id])
      end
    end

    context 'organizer' do
      it_behaves_like '#role?', :organizer, 'orgAnizer', true
      it_behaves_like '#role?', :organizer, 'adMin', false
      it_behaves_like '#role?', :organizer, 'partiCipant', false
    end
  end
end
