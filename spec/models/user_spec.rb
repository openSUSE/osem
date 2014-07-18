require 'spec_helper'

describe User do

  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_conference_1_role ) { create(:organizer_conference_1_role ) }
  let!(:organizer) { create(:organizer_conference_1 ) }

  it 'returns the correct role' do
    participant = create(:user, email: 'participant@example.de')
    expect(organizer.roles.first).to eq(organizer_conference_1_role)
    expect(participant.roles.first).to eq(organizer_conference_1_role)
  end

  it 'returns the correct roles' do
    roles = [participant_role.id, organizer_conference_1_role.id]
    user_with_all_roles = create(:user, email: 'participant@example.de')
    user_with_all_roles.role_ids = roles
    user_with_all_roles.save

    expect(user_with_all_roles.roles.length).to eq(2)
    expect(user_with_all_roles.roles[0]).to eq(participant_role)
    expect(user_with_all_roles.roles[1]).to eq(organizer_conference_1_role )
  end

  describe '#role?' do
    shared_examples '#role?' do |user, role, expected|
      it "returns #{expected} for #{role}" do
        user_obj = create(user, email: 'e@example.com')
        expect(user_obj.has_role?(role)).to be expected
        expect(user_obj.has_role?(role.downcase)).to be expected
        expect(user_obj.has_role?(role.upcase)).to be expected
        expect(user_obj.has_role?(role.downcase.capitalize)).to be expected
      end
    end

    context 'organizer' do
      it_behaves_like '#role?', :organizer_conference_1_role, 'oRganIzeR', true
      it_behaves_like '#role?', :organizer_conference_1_role, 'partiCipant', false

      it 'assigns first user organizer role' do
        expect(organizer.has_role?('organizer', Conference.first)).to be true
        expect(organizer.role_ids).to match_array([organizer_conference_1_role.id])
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
