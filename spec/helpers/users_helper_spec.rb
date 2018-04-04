# frozen_string_literal: true

require 'spec_helper'

describe UsersHelper, type: :helper do
  describe 'show_roles' do
    it 'formats the hash passed' do
      roles = { 'organizer' => %w[oSC16 oSC15], 'cfp' => ['oSC16'] }
      expect(show_roles(roles)).to eq 'Organizer (oSC16, oSC15), Cfp (oSC16)'
    end
  end
end
