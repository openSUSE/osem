# frozen_string_literal: true

require 'spec_helper'

describe Role do
  let(:conference) { create(:conference) }
  let!(:organizer_role) { Role.find_or_create_by(name: 'organizer', resource: conference) }
  let!(:cfp_role) { Role.find_or_create_by(name: 'cfp', resource: conference) }
  let!(:organizer) { create(:organizer, resource: conference) }
  let(:user) { create(:user) }

  it 'get_users' do
    expect(organizer_role.users).to include organizer
    expect(organizer_role.users.count).to eq 1
    expect(cfp_role.users).to eq []
  end

  it 'does not delete role when last user of role is removed' do
    user.add_role :cfp, conference
    expect(cfp_role.users).to include user
    user.remove_role :cfp, conference
    expect(cfp_role.users).to eq []
    expect(conference.roles.count).to eq 4
  end
end
