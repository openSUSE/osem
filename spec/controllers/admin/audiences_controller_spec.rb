require 'spec_helper'

describe Admin::AudiencesController do

  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  let(:conference) { create(:conference) }
  let(:admin) { create(:admin) }
  let(:organizer) { create(:organizer) }
  let(:participant) { create(:participant) }

  shared_examples 'access as administration or organizer' do

    before do
      conference.audience = create(:audience)
    end

    describe 'PATCH #update' do

      context 'valid attributes' do

        it 'locates the requested audience object' do
          patch :update, conference_id: conference.short_title, conference: attributes_for(:audience)
          expect(assigns(:audience)).to eq(conference.audience)
        end

        it 'changes audience attributes' do
          patch :update, conference_id: conference.short_title, audience:
              attributes_for(:audience,
                             registration_description: 'Test')

          conference.reload
          expect(conference.audience.registration_description).to eq('Test')
        end

        it 'redirects to the updated conference' do
          patch :update, conference_id: conference.short_title, audience:
              attributes_for(:audience)
          conference.reload
          expect(response).to redirect_to edit_admin_conference_audience_path(
                                              conference.short_title)
        end

        it 'sends email notification on conference registration date update' do
          mailer = double
          allow(mailer).to receive(:deliver)
          conference.email_settings = create(:email_settings)
          conference.audience = create(:audience,
                                       registration_start_date: Date.today,
                                       registration_end_date: Date.today + 2.days)

          patch :update, conference_id: conference.short_title, audience:
              attributes_for(:audience,
                             registration_start_date: Date.today + 2.days,
                             registration_end_date: Date.today + 4.days)
          conference.reload
          allow(Mailbot).to receive(:conference_registration_date_update_mail).and_return(mailer)
        end
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested conference to conference' do
        get :edit, conference_id: conference.short_title
        expect(assigns(:audience)).to eq conference.audience
      end

      it 'renders the show template' do
        get :edit, conference_id: conference.short_title
        expect(response).to render_template :edit
      end
    end
  end

  describe 'administrator access' do

    before do
      sign_in(admin)
    end

    it_behaves_like 'access as administration or organizer'

  end

  describe 'organizer access' do

    before(:each) do
      sign_in(organizer)
    end

    it_behaves_like 'access as administration or organizer'

  end
end
