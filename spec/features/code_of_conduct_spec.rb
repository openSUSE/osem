require 'spec_helper'

feature 'Code of Conduct:' do
  let!(:organization) { create(:organization) }
  let!(:conference) { create(:full_conference, organization: organization) }
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

      context 'on a conference' do
        it 'is linked from the index' do
          visit conferences_path
          within "#conference-#{conference.id}" do
            click_on 'Code of Conduct'
          end
          expect(page).to have_text(sample_text)
        end

        it 'is included in the splash page', js: true do
          visit conference_path(conference)
          click_on 'Code of Conduct'
          expect(page).to have_text(sample_text)
        end
      end
    end

    describe 'as a participant' do
      let!(:organization) { create(:organization, code_of_conduct: sample_text) }
      let!(:participant) { create(:user) }

      before { sign_in participant }

      it 'must be accepted', js: true do
        visit conferences_path
        within "#conference-#{conference.id}" do
          click_on 'Register'
        end
        expect(page).to have_text('I have read and accept the Code of Conduct')
        expect(page).not_to have_text(sample_text)
        within 'form' do
          click_on 'Code of Conduct'
        end
        expect(page).to have_content(sample_text)
        find('button.close').click
        click_on 'Register'
        expect(conference.user_registered?(participant)).to be_falsey
        expect(page).to have_content('Accepted code of conduct must be accepted')
        check 'registration[accepted_code_of_conduct]'
        click_on 'Register'
        expect(conference.user_registered?(participant)).to be_truthy
        visit conference_conference_registration_path(conference)
        expect(page).to have_content('You have accepted the Code of Conduct')
      end
    end
  end
end
