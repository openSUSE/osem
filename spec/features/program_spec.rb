require 'spec_helper'

feature Program do

  let!(:conference) { create(:conference) }
  let!(:program) { conference.program }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  describe 'edit program' do
    before :each do
      sign_in organizer
    end

  end
end
