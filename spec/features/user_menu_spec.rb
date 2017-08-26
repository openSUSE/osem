require 'spec_helper'

feature '_user_menu' do
  let(:admin) { create(:admin) }
  subject { page }
  before { sign_in admin }

  scenario 'when no organization is present', feature: true, js: true do
    visit root_path
    click_link admin.name

    is_expected.to have_text('New Organization')
    is_expected.to_not have_text('New Conference')
  end

  scenario 'when organization is present', feature: true, js: true do
    create(:organization)
    visit root_path
    click_link admin.name

    is_expected.to_not have_text('New Organization')
    is_expected.to have_text('New Conference')
  end
end
