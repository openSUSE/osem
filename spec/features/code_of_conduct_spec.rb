require 'spec_helper'

feature 'Code of Conduct:' do
  let!(:organization) { create(:organization) }
  let(:admin) { create(:admin) }
  let(:sample_text) { Faker::Lorem.paragraph }

  context 'on an organization' do
    describe 'as admin' do
      before { sign_in admin }

      it 'can add and remove' do
        visit admin_organizations_path
        within "tr#organization-#{organization.id}" do
          expect(page).not_to have_css 'i.fa-check'
          click_on 'Edit'
        end
        expect(page).to have_field 'organization[code_of_conduct]', with: ''
        fill_in 'organization[code_of_conduct]', with: sample_text
        click_on 'Update Organization'
        within "tr#organization-#{organization.id}" do
          expect(page).to have_css 'i.fa-check'
          click_on 'Edit'
        end
        expect(page).to have_field 'organization[code_of_conduct]', with: sample_text
        fill_in 'organization[code_of_conduct]', with: ''
        click_on 'Update Organization'
        within "tr#organization-#{organization.id}" do
          expect(page).not_to have_css 'i.fa-check'
        end
      end
    end

    describe 'anonymously' do
      let!(:organization) { create(:organization, code_of_conduct: sample_text) }

      context 'on the organization' do
        it 'can be read' do
          visit organizations_path
          within "#organization-#{organization.id}" do
            click_on 'Code of Conduct'
          end
          expect(page).to have_text(sample_text)
        end
      end
    end
  end
end
