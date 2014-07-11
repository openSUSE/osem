require 'spec_helper'

describe User do

  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_role) { create(:organizer_role) }
  let!(:organizer) { create(:user) }

  it 'returns the correct role' do
    participant = create(:user, email: 'participant@example.de')
    expect(organizer.roles.first).to eq(organizer_role)
    expect(participant.roles.first).to eq(participant_role)
  end

  it 'returns the correct roles' do
    roles = [participant_role.id, organizer_role.id]
    user_with_all_roles = create(:user, email: 'participant@example.de')
    user_with_all_roles.role_ids = roles
    user_with_all_roles.save

    expect(user_with_all_roles.roles.length).to eq(2)
    expect(user_with_all_roles.roles[0]).to eq(participant_role)
    expect(user_with_all_roles.roles[1]).to eq(organizer_role)
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

    context 'organizer' do
      it_behaves_like '#role?', :organizer, 'oRganIzeR', true
      it_behaves_like '#role?', :organizer, 'partiCipant', false

      it 'assigns first user organizer role' do
        expect(organizer.role?('Organizer')).to be true
        expect(organizer.role_ids).to match_array([organizer_role.id])
      end
    end

    context 'participant' do
      it_behaves_like '#role?', :participant, 'adMin', false
      it_behaves_like '#role?', :participant, 'partiCipant', true

      it 'assigns second user participant role' do
        participant = create(:user, email: 'participant@example.de')
        expect(participant.role_ids).to match_array([participant_role.id])
      end
    end
  end
end
