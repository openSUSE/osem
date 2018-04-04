# frozen_string_literal: true

require 'spec_helper'

feature 'Routing', type: :routing do
  let(:conference) { create(:conference) }

  context 'the root URL' do
    it 'routes to conferences#index' do
      expect(get: '/').to route_to(
        controller: 'conferences',
        action:     'index'
      )
    end

    # FIXME: this doesn't work due to routes being statically loaded
    # See https://github.com/rspec/rspec-rails/issues/817 for example
    # context 'with OSEM_ROOT_CONFERENCE set' do
    #   it 'redirects to the conference' do
    #     ClimateControl.modify OSEM_ROOT_CONFERENCE: conference.short_title do
    #       expect(get: '/').to route_to(
    #         controller: 'conferences',
    #         action:     'show',
    #         id:         conference.short_title
    #       )
    #     end
    #   end
    # end
  end
end
