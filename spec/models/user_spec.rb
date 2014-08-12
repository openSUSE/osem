require 'spec_helper'

describe User do

  # It is necessary to use bang version of let to build roles before user
  let!(:admin) { create(:admin) }
  let!(:participant) { create(:participant) }
  let!(:organizer_conference_1) { create(:organizer_conference_1 ) }
  let!(:organizer_conference_1_role) { Role.where(resource_type: 'Conference', resource_id: 1).first }

  it 'returns the correct role' do
    expect(organizer_conference_1.roles.first).to eq(organizer_conference_1_role)
  end

  it 'returns the correct roles' do
    participant_role = create(:participant_role)
    roles = [participant_role.id, organizer_conference_1_role.id]
    user_with_all_roles = create(:user, email: 'participant@example.de')
    user_with_all_roles.role_ids = roles
    user_with_all_roles.save

    expect(user_with_all_roles.roles.length).to eq(2)
    expect(user_with_all_roles.roles[0]).to eq(participant_role)
    expect(user_with_all_roles.roles[1]).to eq(organizer_conference_1_role )
  end

  describe '#has_role?' do
    shared_examples '#role?' do |user, role, expected|
      it "returns #{expected} for #{role}" do
        user_obj = create(user, email: 'e@example.com')
        expect(user_obj.has_role?(role.downcase, :any)).to be expected
      end
    end

    context 'organizer' do
      it_behaves_like '#role?', :organizer_conference_1, 'organizer', true
      it_behaves_like '#role?', :organizer_conference_1, 'participant', false
    end

    context 'admin' do
      it 'assigns first user admin role' do
        expect(User.first.is_admin).to be true
        expect(admin.is_admin).to eq(true)
      end
    end

    context 'participant' do
      it_behaves_like '#role?', :participant, 'adMin', false
      it_behaves_like '#role?', :participant, 'participant', true

#       it 'assigns second user participant role' do
#         participant = create(:user, email: 'participant@example.de')
#         expect(participant.role_ids).to match_array([participant_role.id])
#       end
    end
  end
end
